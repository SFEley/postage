class Postage
  class Configuration
    # == Constants ==========================================================
    
    DEFAULT_HOSTNAME = 'http://postageapp.com'.freeze
    CONFIG_FILES = [
      "#{Rails.root}/config/postage.yml",
      "#{Rails.root}/config/postage.yaml",
      "#{Rails.root}/config/postageapp.yml",
      "#{Rails.root}/config/postageapp.yaml"
    ].freeze

    DEFAULT_CONFIGURATION = {
      :url => DEFAULT_HOSTNAME,
      :queue_path => "#{Rails.root}/tmp/postage",
      :api_format => :json
    }.freeze
    
    # == Class Methods ======================================================

    # :nodoc:
    def self.config_file_path
      CONFIG_FILES.find do |path|
        File.exist?(path)
      end
    end
    
    # Returns the default path to the configuration file
    def self.default_config_file_path
      config_file_found or CONFIG_FILES.first
    end
    
    # == Instance Methods ===================================================

    # Creates a new Postage::Configuration instance by reading from the
    # configuration file.
    # +env+ The Rails environment to load
    def initialize(env)
      config_file = self.class.config_file_path
      
      @env_config = DEFAULT_CONFIGURATION
      
      if (@config = (config_file and YAML.load(File.open(config_file))))
        [ @config['defaults'], @config[env] ].compact.each do |options|
          @env_config = @env_config.merge(options.symbolize_keys)
        end
      end
      
      # Convert some options to Symbol from String
      [ :api_format ].each do |k|
        @env_config[k] = @env_config[k].to_sym
      end
    end
    
    # Will return +true+ if a configuration file was found and loaded, or
    # +false+ otherwise.
    def exists?
      @env_config != DEFAULT_CONFIGURATION
    end
    
    # Creates the configuration file with standard defaults defined.
    def create!
      open(self.class.default_config_file_path, 'w') do |fh|
        fh.puts *[
          "defaults: &defaults",
          @env_config.collect { |k,v| "  #{k}: #{v}" },
          "#{Rails.env}:",
          "  <<: *defaults"
        ].flatten
      end
    end
    
    # -- Accessors and Mutators ---------------------------------------------
    
    # Returns the base URL used for API calls
    def url
      @env_config[:url]
    end

    def url=(value)
      @env_config[:url] = value.to_s
    end
    
    # Returns the unique key used for API calls.
    def api_key
      @env_config[:api_key]
    end

    def api_key=(value)
      @env_config[:api_key] = value.to_s
    end

    # Returns the format used for API calls.
    def api_format
      @env_config[:api_format]
    end

    def api_key=(value)
      @env_config[:api_format] = value.to_s
    end
    
    # Returns an array of the recipient(s) the message will be sent to,
    # regardless of original destination or nil if this is not defined.
    def force_recipient
      @env_config[:force_recipient]
    end

    def force_recipient=(values)
      values = [ values ].flatten.collect(&:to_s)
   
      @env_config[:force_recipient] = values.empty? ? nil : values
    end

    # Returns the current directory where messages will be saved if they
    # cannot be delivered to the Postage application in a timely manner.
    def queue_path
      @env_config[:queue_path]
    end

    def queue_path=(value)
      @env_config[:queue_path] = value.to_s
    end
  end
end