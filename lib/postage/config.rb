class Postage
  class Config
    # =======================================================================
    # :section: Constants
    
    BASE_PATH = Rails.root rescue RailsEnvironment.default.root
    
    DEFAULT_API_KEY = 'INSERT_VALID_API_KEY_HERE'.freeze
    
    DEFAULT_HOSTNAME = 'http://postageapp.com'.freeze
    CONFIG_FILES = [
      File.join(BASE_PATH, 'config', 'postage.yml'),
      File.join(BASE_PATH, 'config', 'postage.yaml'),
      File.join(BASE_PATH, 'config', 'postageapp.yml'),
      File.join(BASE_PATH, 'config', 'postageapp.yaml')
    ].freeze

    DEFAULT_CONFIGURATION = {
      :url => DEFAULT_HOSTNAME,
      :queue_path => File.join(BASE_PATH, 'tmp', 'postage'),
      :api_format => :json
    }.freeze

    # =======================================================================
    # :section: Properties
    
    attr_reader :file_path
    
    # =======================================================================
    # :section: Class Methods 

    # :nodoc:
    def self.file_path
      @file_path ||=
        CONFIG_FILES.find do |path|
          File.exist?(path)
        end
    end

    def self.file_path=(path)
      @file_path = path.to_s
    end

    # Returns +true+ if the configuration file exists.
    def self.exists?
      !!file_path
    end
    
    # Returns the default path to the configuration file.
    def self.default_config_file_path
      file_path or CONFIG_FILES.first
    end
    
    # Returns the current Rails environment.
    def self.environment
      Rails.env
    rescue
      ENV['RAILS_ENV'] || 'development'
    end
    
    # Creates a configuration file with safe defaults
    def self.create!
      new.create!
    end
    
    # =======================================================================
    # :section: Instance Methods

    # Creates a new Postage::Configuration instance by reading from the
    # configuration file.
    # * +env+ is the Rails environment to load.
    def initialize(env = nil)
      env ||= self.class.environment
      
      @file_path = self.class.file_path
      
      @env_config = { }.merge(DEFAULT_CONFIGURATION)
      
      begin
        @config = YAML.load(File.open(@file_path))

        [ @config['defaults'], @config[env] ].compact.each do |options|
          # NOTE: Hash#symbolize_keys not present during install phase
          @env_config = @env_config.merge(options.inject({ }) { |h, (k, v)| h[k.to_sym] = v; h })
        end
      rescue => e
        @file_path = self.class.default_config_file_path
        @config_exception = e.to_s
      end
      
      # Convert some options to Symbol from String
      [ :api_format ].each do |k|
        @env_config[k] = @env_config[k].to_sym
      end
    end
    
    # Will return +true+ if a configuration file was found and loaded, or
    # +false+ otherwise.
    def exists?
      File.exists?(@file_path)
    end
    
    # Creates the configuration file with standard defaults defined.
    def create!
      @file_path = self.class.default_config_file_path
      puts "CREATE: #{@file_path}"
      
      open(@file_path, 'w') do |fh|
        fh.puts *[
          "defaults: &defaults",
          "  \# Keys defined here will be loaded by default into all environments",
          "#{self.class.environment}:",
          "  \# Register your project with #{DEFAULT_HOSTNAME}/ for a valid API key",
          "  api_key: #{DEFAULT_API_KEY}"
        ].flatten
      end
    rescue Errno::EACCES
      raise Postage::Exception, "Could not create configuration file #{@file_path}"
    end
    
    # -----------------------------------------------------------------------
    # == Accessors and Mutators
    
    # Returns the base URL used for API calls
    def url(path = nil)
      @env_config[:url] + path.to_s
    end

    # :nodoc:
    def url=(value)
      @env_config[:url] = value.to_s
    end
    
    # Returns the unique key used for API calls.
    def api_key
      @env_config[:api_key]
    end

    # :nodoc:
    def api_key=(value)
      @env_config[:api_key] = value.to_s
    end
    
    # Returns +true+ if using the default API key, +false+ otherwise.
    def default_api_key?
      self.api_key == DEFAULT_API_KEY
    end

    # Returns the format used for API calls.
    def api_format
      @env_config[:api_format]
    end

    # :nodoc:
    def api_key=(value)
      @env_config[:api_format] = value.to_s
    end
    
    # Returns an array of the recipient(s) the message will be sent to,
    # regardless of original destination or +nil+ if this is not defined.
    def force_recipient
      @env_config[:force_recipient]
    end

    # :nodoc:
    def force_recipient=(values)
      values = [ values ].flatten.collect(&:to_s)
   
      @env_config[:force_recipient] = values.empty? ? nil : values
    end

    # Returns the current directory where messages will be saved if they
    # cannot be delivered to the Postage application in a timely manner.
    def queue_path
      @env_config[:queue_path]
    end

    # :nodoc:
    def queue_path=(value)
      @env_config[:queue_path] = value.to_s
    end

    # Returns the path of the configuration file that was loaded, or +nil+
    # if no file was loaded
    def file_path
      @file_path
    end
    
    # Returns the configuration as a Hash with Symbol keys.
    def to_h
      @env_config
    end
    
    # :nodoc:
    def inspect
      @env_config.inspect
    end
    
    # Returns any exception encountered when the configuration file was read or
    # +nil+ if no exception occurred.
    def read_exception
      @config_exception
    end
  end
end