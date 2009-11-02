module Postage
  
  PLUGIN_VERSION  = '0.0.1'
  API_VERSION     = '1.0'
  
  require 'logger'
  require 'postage/mailer'
  require 'postage/request'
  require 'postage/response'
  
  class << self
    attr_accessor :api_key, :api_version, :url, :recipient_override, :environments, :log
  end
    
  # Logging mechanism
  def self.log
    logfile_path = if defined?(Rails)
      "#{Rails.root}/log/postage_#{Rails.env}.log"
    else
      "#{File.expand_path('../test', File.dirname(__FILE__))}/postage_test.log"
    end
    
    @log ||= begin
      logfile = File.open(logfile_path, 'a')
      logfile.sync = true
      Logger.new(logfile)
    end
  end
    
  # API version on the PostageApp server
  def self.api_version
    @api_version ||= API_VERSION
  end
    
  # Url plugin is using to communicated with PostageApp
  def self.url
    @url ||= 'http://api.postageapp.com'
  end
    
  # Defines Rails environments when Postage kicks in instead of ActiveMailer
  # This so we don't send messages during development / testing when it's not
  # neccessary to hit PostageApp
  def self.environments
    @environments ||= [:production]
  end
    
  # Set up this configuration in /config/initializers/postage.rb
  # 
  #   Postage.configure do |config|
  #     config.api_key = '1234567890abcdef'
  #   end
  #
  def self.configure
    yield self
  end
    
  # Sends a message to PostageApp for the project specified by the api_key
  # For more information please check postageapp.com/docs
  # Accepts following parameters:
  #
  # message - either a hash of this format:
  #   { 'text/html'  => 'html message content 
  #     'text/plain' => 'text message content' }
  # or a string that specifies the name of the message template that is 
  # set up on PostageApp for this project
  #
  # recipients - this could be a string, an array of strings (email addresses)
  # or a hash of the following format:
  # { 'bob@bob.com'  => {'variable' => 'variable_value} 
  #   'joe@smith.com => {'variable' => 'variable_value} }
  #
  # variables - a hash of varaible_name => variable_value pairs
  # they are used for content replacement...
  #
  # headers - a hash of header names and their values
  #
  def self.send_message(message, recipients, variables = nil, headers = nil)
    arguments = {}
    arguments[:recipients] = recipients
    
    case (message)
      when String then arguments[:template_name] = message
      when Hash   then arguments[:message]       = message
    end
    
    arguments[:variables] = variables unless variables.blank?
    arguments[:headers]   = headers   unless headers.blank?
    
    unless Postage.recipient_override.blank?
      arguments[:recipient_override] = Postage.recipient_override
    end
    
    Postage::Request.new(:send_message, arguments).call!
  end
end

