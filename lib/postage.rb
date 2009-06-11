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
  # == Constants ============================================================
  
  POSTAGE_API_VERSION = '0.1.0'
  VERSION = '0.1.2'

  # == Utility Classes ======================================================

  class Exception < ::Exception
  end
  
  class Configuration
    # == Constants ==========================================================
    
    DEFAULT_HOSTNAME = 'http://postageapp.com'.freeze
    CONFIG_FILES = [
      "#{RAILS_ROOT}/config/postage.yml",
      "#{RAILS_ROOT}/config/postage.yaml",
      "#{RAILS_ROOT}/config/postageapp.yml",
      "#{RAILS_ROOT}/config/postageapp.yaml"
    ].freeze

    DEFAULT_CONFIGURATION = {
      :url => DEFAULT_HOSTNAME
    }.freeze
    
    # == Class Methods ======================================================

    # :nodoc:
    def self.config_file_found
      CONFIG_FILES.find do |path|
        File.exist?(path)
      end
    end
    
    # Returns the default path to the configuration file
    def self.default_path
      config_file_found or CONFIG_FILES.first
    end
    
    # == Instance Methods ===================================================

    # Creates a new Postage::Configuration instance by reading from the
    # configuration file.
    # +env+ The Rails environment to load
    def initialize(env)
      config_file = self.class.config_file_found
      
      @env_config = DEFAULT_CONFIGURATION
      
      if (@config = (config_file and YAML.load(File.open(config_file))))
        [ @config['defaults'], @config[env] ].each do |options|
          if (options)
            @env_config = @env_config.merge(options.symbolize_keys)
          end
        end
      end
    end
    
    # Will return +true+ if a configuration file was found and loaded, or
    # +false+ otherwise.
    def exists?
      @env_config != DEFAULT_CONFIGURATION
    end
    
    # Returns a particular configuration option.
    def [](key)
      @env_config[key.to_sym]
    end

    def []=(key, value)
      @env_config[key.to_sym] = value
    end
    
    # Returns the base URL used for API calls
    def url
      @env_config[:url]
    end
    
    # Returns the unique key used for API calls.
    def api_key
      @env_config[:api_key]
    end
  end
  
  # == Extensions ===========================================================
  
  include HTTParty
  format :json
  
  # == Class Methods ========================================================
  
  def self.config
    @config ||= Configuration.new(Rails.env)
  end
  
  # == Instance Methods =====================================================

  # An instance of Postage may be created with options that override those
  # found in the configuration file.
  def initialize(options = nil)
    options ||= { }
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
    
    if (options[:force_recipient])
      arguments[:transmission] ||= { }
      arguments[:transmission][:recipient] = options[:force_recipient]
    end

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
