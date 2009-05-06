class Postage
  # == Constants ============================================================
  
  POSTAGE_API_VERSION = '0.1.0'
  VERSION = '0.1.1'

  # == Utility Classes ======================================================

  class Exception < ::Exception
  end
  
  class Configuration
    # == Constants ==========================================================
    
    DEFAULT_HOSTNAME = 'http://postageapp.com'.freeze
    CONFIG_FILES = [
      "#{RAILS_ROOT}/config/postage.yaml",
      "#{RAILS_ROOT}/config/postage.yml",
      "#{RAILS_ROOT}/config/postageapp.yaml",
      "#{RAILS_ROOT}/config/postageapp.yml"
    ].freeze
    
    # == Class Methods ======================================================

    def self.defaults
      {
        :url => DEFAULT_HOSTNAME
      }
    end
    
    # == Instance Methods ===================================================

    def initialize(env)
      config_file = CONFIG_FILES.find do |path|
        File.exist?(path)
      end
      
      @config = (config_file and YAML.load(File.open(config_file)))
      
      @env_config = self.class.defaults
      
      [ @config['defaults'], @config[env] ].each do |options|
        if (options)
          @env_config = @env_config.merge(options.symbolize_keys)
        end
      end
    end
    
    def [](key)
      @env_config[key.to_sym]
    end
    
    def url
      @env_config[:url]
    end
    
    def api_key
      @env_config[:api_key]
    end
  end
  
  # == Extensions ===========================================================
  
  include HTTParty
  format :xml
  
  # == Class Methods ========================================================
  
  def self.config
    @config ||= Configuration.new(Rails.respond_to?(:env) ? Rails.env : ENV['RAILS_ENV'])
  end
  
  # == Instance Methods =====================================================

  def initialize(options = { })
    @api_key = options[:api_key] || self.class.config.api_key
    @format = (options[:format] || :json).to_sym
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
    
    self.api_call(:send_message, :arguments => arguments)
  end
  
protected
  def api_call(action, params)
    self.class.post(
      "#{self.class.config.url}/api/#{@api_key}/#{action}.#{@format}",
      :headers => {
        'Content-Type' => "application/#{@format}"
      },
      :body => encode_params(params, @format),
      :format => @format
    )
  end
  
  def encode_params(hash, format = :yaml)
    case (format)
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
