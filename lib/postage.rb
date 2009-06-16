# = Overview:
# A simple Ruby on Rails plugin for interfacing with Postage.
#
# An account on the Postage App site is required for any API calls.
#
# ---
# = Usage:
#   
#   require 'postage'
#   
#   Postage.new.send_message('message_name', 'recipient@example.com')

# Author:: Scott Tadman (scott@twg.ca), Jack Neto (jack@twg.ca)
# Copyright:: Copyright (c) 2009 The Working Group Inc.
# License:: Distributes under the same terms as Ruby

# http://e-huned.com/2009/06/11/monkey-patch-httparty-to-use-a-timeout/
module HTTParty
  class Request
  private
    def http
      http = Net::HTTP.new(uri.host, uri.port, options[:http_proxyaddr], options[:http_proxyport])
      http.use_ssl = (uri.port == 443)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.open_timeout = http.read_timeout = options[:timeout].to_i if (options[:timeout].to_i > 0)
      http
    end
  end
end

class Postage
  # == Autoload =============================================================
  
  autoload(:Config, 'postage/config')
  autoload(:Mailer, 'postage/mailer')

  # == Constants ============================================================
  
  POSTAGE_API_VERSION = '0.1.0'
  VERSION = '0.2.0'

  # == Utility Classes ======================================================

  class Exception < ::Exception
  end
  
  # == Extensions ===========================================================

  # Installation procedure requires a functional Postage class even if
  # HTTParty is not loaded properly.
  begin
    include HTTParty
    format :json
  rescue
  end
  
  # == Class Methods ========================================================
  
  def self.config
    @config ||= Config.new
  end
  
  def self.queued_transactions
    Dir.entries(config.queue_path).select do |file|
      file.match(/\.yaml$/)
    end
  end
  
  def self.queue
    queued_transactions.collect do |file|
      path = File.join(config.queue_path, file)
      reason = nil
      url = nil

      begin
        fh = open(path)
        reason = fh.readline.sub(/^#\s*/, '').chomp
        url = fh.readline.sub(/^#\s*/, '').chomp
      rescue
        reason = "ERROR: Could not open #{path}"
      end

      [ file, reason, url ]
    end
  end
  
  def self.retry!
    require 'timeout'
    
    queued_transactions.each do |filename|
      path = File.join(config.queue_path, filename)
      file = File.new(path)

      begin
        puts filename

        locked = false

        Timeout::timeout(1) do
          file.flock(File::LOCK_EX)
          locked = true
        end

        if (locked)
          params = YAML.load(open(path))

          puts "\tPosting to #{params.first}"
          post(*params)
        
          File.unlink(path)

          puts "\tSent."
        end
      rescue Timeout::Error, Exception => e
        STDERR.puts(e.to_s)
        # Skip for now, can't finish
      rescue => e
        STDERR.puts(e.to_s)
        # YAML-related errors
      ensure
        file.flock(File::LOCK_UN)
      end
    end
  end
  
  # == Instance Methods =====================================================

  # An instance of Postage may be created with options that override those
  # found in the configuration file.
  def initialize(config = nil)
    @config = config || self.class.config
    
    @api_key = @config.api_key
    @api_format = @config.api_format
    @force_recipient = @config.api_format
  end
  
  def test
    self.api_call(:project_info)
  end
  
  def send_message(message, recipients, variables = nil, headers = nil)
    arguments = {
      :recipients => recipients
    }
    
    case (message)
    when String
      arguments[:message_name] = message
    when Hash
      arguments[:message] = message
    end
    
    arguments[:variables] = variables unless (variables.blank?)
    arguments[:headers] = headers unless (headers.blank?)
    
    if (@force_recipient)
      arguments[:transmission] ||= { }
      arguments[:transmission][:recipient] = @force_recipient
    end

    self.api_call(:send_message, :arguments => arguments)
  end
  
protected
  def api_call(action, params = nil)
    make_reliable_post(
      action,
      "#{self.class.config.url}/api/#{@api_key}/#{action}.#{@api_format}",
      :headers => {
        'Content-Type' => "application/#{@api_format}"
      },
      :body => encode_params(params, @api_format),
      :format => @api_format,
      :timeout => 2
    )
  end
  
  def make_reliable_post(action, url, params)
    self.class.post(url, params)
  rescue HTTParty::Parsers::JSON::ParseError, Timeout::Error, Exception => e
    # Timeout on connection
    save_to_queue(action, "\# Exception: #{e.class} (#{e})\n\# #{url}\n" + [ url, params ].to_yaml)
  end
  
  def save_to_queue(action, content = nil)
    queue_path = self.class.config.queue_path
    
    FileUtils.mkdir_p(queue_path) unless (File.exist?(queue_path))
    
    open(File.join(queue_path, "%.9f.%06d.%s.yaml" % [ Time.now.to_f, $$, action ]), 'w') do |fh|
      fh.write(content) if (content)
      yield(fh) if (block_given?)
    end
  end
  
  def encode_params(hash, api_format = :yaml)
    return '' unless (hash)
    
    case (api_format)
    when :xml
      name = hash.keys.first.to_s
      data = hash.values.first

      data.to_xml(:root => name, :type => 'hash')
    when :yaml
      hash.to_yaml
    else
      hash.to_json
    end
  end
end
