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

class Postage
  # == Autoload =============================================================
  
  autoload(:Config, 'postage/config')
  autoload(:Mailer, 'postage/mailer')
  autoload(:Response, 'postage/response')
  autoload(:Result, 'postage/result')
  autoload(:Request, 'postage/request')

  # == Constants ============================================================
  
  POSTAGE_API_VERSION = '0.2.0'
  VERSION = '0.2.2'

  UNIQUE_ID_LETTERS = [ ('a'..'z'), ('A'..'Z'), ('0'..'9') ].collect do |c|
    c.collect 
  end.flatten.freeze

  UNIQUE_ID_LETTERS_COUNT = UNIQUE_ID_LETTERS.length

  # == Utility Classes ======================================================

  class Exception < ::Exception
  end
  
  # == Class Methods ========================================================
  
  def self.generate_unique_id(length = 20)
    (1..length).collect do
      UNIQUE_ID_LETTERS[ActiveSupport::SecureRandom.random_number(UNIQUE_ID_LETTERS_COUNT)]
    end.to_s
  end

  def self.config(reload = false)
    @config = nil if (reload)
    @config ||= Config.new
  end
  
  def self.queued_transactions
    Dir.entries(config.queue_path).select do |file|
      file.match(/\.yaml$/)
    end
  end
  
  def self.queue!(filename, content = nil)
    queue_path = config.queue_path

    unless (File.exist?(queue_path))
      FileUtils.mkdir_p(queue_path)
    end
    
    open(File.join(queue_path, filename), 'w') do |fh|
      fh.write(content) if (content)
      yield(fh) if (block_given?)
    end
  end
  
  def self.queue
    queued_transactions.collect do |file|
      path = File.join(config.queue_path, file)
      info = [ file ]

      begin
        fh = open(path)
        
        while (line = fh.readline) do
          if (line.match(/^#/))
            info << line.sub(/\#\s*/, '').chomp
          else
            break
          end
        end
      rescue
        reason = "Error: Could not open #{path}"
      end
      
      info
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
          request = Request.load(path)

          response = request.post!
          
          if (response.error?)
            puts "\tFailed: #{response.error}"
          else
            File.unlink(path)
            puts "\tSent."
          end
        end
      rescue Timeout::Error, Exception => e
        # Skip for now, can't finish
      ensure
        file.flock(File::LOCK_UN)
      end
    end
  end
  
  def self.send_message(message, recipients, variables = nil, headers = nil)
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
    
    if (config.force_recipient)
      arguments[:transmission] ||= { }
      arguments[:transmission][:recipient] = config.force_recipient
    end

    Postage::Request.new(:send_message, arguments).call!
  end

  def self.test
    Postage::Request.new(:project_info).call!
  end

  # == Instance Methods =====================================================
end
