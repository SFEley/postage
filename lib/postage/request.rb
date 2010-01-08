class Postage::Request
  
  require 'httparty'
  include HTTParty
  format :json
  
  HEADERS = {
    'Content-type'             => 'application/json',
    'Accept'                   => 'text/json, application/json',
    'X-Postage-Client-Name'    => 'PostagePlugin',
    'X-Postage-Client-Version' => Postage::PLUGIN_VERSION
  }
  
  attr_accessor :api_method,
                :arguments,
                :response
  
  def initialize(api_method = nil, arguments = {})
    @api_method = api_method
    @arguments  = arguments || {}
  end
  
  def call_url
    "#{Postage.url}/v.#{Postage::API_VERSION}/#{self.api_method}.json"
  end
  
  def uid
    @uid ||= Time.now.to_f.to_s
  end
  
  # Returns a json response as recieved from the PostageApp server
  # Upon internal failure nil is returned
  def call(call_url = self.call_url, arguments = self.arguments)
    Postage.logger.info "Sending Request [UID: #{self.uid} URL: #{call_url}] \n#{arguments.inspect}\n"
    
    self.arguments[:uid]              = self.uid
    self.arguments[:plugin_version]   = Postage::PLUGIN_VERSION
    
    body = { :api_key => Postage.api_key, :arguments => arguments }.to_json
    Timeout::timeout(5) do
      self.response = self.class.post( call_url, :headers => HEADERS, :body => body )
    end
    
    Postage.logger.info "Received Response [UID: #{self.uid}] \n#{self.response.inspect}\n"
    return Postage::Response.new(self.response)
    
  rescue Timeout::Error, SocketError, Exception => e
    Postage.logger.error "Failure [UID: #{self.uid}] \n#{e.inspect}"
    
    store_failed_request(e)
    return nil # no response generated
  end
  
protected
  
  def store_failed_request(e)
    return unless Postage.failed_calls.include?(self.api_method.to_s)
    
    # notification for hoptoad users
    notify_hoptoad(e) if defined?(Hoptoad)
    
    # creating directory, unless if already exists
    FileUtils.mkdir_p(Postage.failed_calls_path) unless File.exists?(Postage.failed_calls_path)
    
    open(File.join(Postage.failed_calls_path, "#{self.uid}.yaml"), 'w') do |f|
      f.write({:url => self.call_url, :arguments => self.arguments}.to_yaml)
    end
    
  end
end
