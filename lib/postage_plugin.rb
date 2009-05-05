class Postage
  # == Utility Classes ======================================================

  class Exception < ::Exception
  end
  
  class Configuration
    # == Constants ==========================================================
    
    DEFAULT_HOSTNAME = 'http://postageapp.com'.freeze
    CONFIG_FILE = "#{RAILS_ROOT}/config/postage.yml".freeze
    
    # == Class Methods ======================================================

    def self.defaults(options)
      {
        :url => DEFAULT_HOSTNAME
      }.merge(options || { })
    end
    
    # == Instance Methods ===================================================

    def initialize(env)
      @config = YAML.load(File.open(CONFIG_FILE))
      
      @env_config = self.class.defaults(@config && @config[env] && @config[env].symbolize_keys)
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
    @format = (options[:format] || :xml).to_sym
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
      :body => encode_params(params)
    )
  end
  
  def encode_params(hash)
    name = hash.keys.first.to_s
    data = hash.values.first
    
    data.to_xml(:root => name, :type => 'hash')
  end
end
