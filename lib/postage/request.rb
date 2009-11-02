# Postage::Request.api_method maps to the possible actions on the PostageApp
# current list is: get_method_list, get_project_info, send_message

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
  
  def initialize(api_method, arguments = {})
    @api_method = api_method
    @arguments  = arguments || {}
  end
  
  def call_url
    "#{Postage.url}/v.#{Postage.api_version}/#{self.api_method}.json"
  end
  
  def uid
    @uid ||= Time.now.to_f.to_s
  end
  
  # Returns a json response as recieved from the PostageApp server
  # Upon internal failure nil is returned
  def call!
    Postage.log.info "Sending Request [UID: #{self.uid} URL: #{call_url}] \n#{self.arguments.inspect}\n"
    
    self.arguments[:uid]              = self.uid
    self.arguments[:plugin_version]   = Postage::PLUGIN_VERSION
    
    Timeout::timeout(2) do
      self.response = self.class.post( call_url, 
        :headers  => HEADERS,
        :body     => { :api_key => Postage.api_key, :arguments => self.arguments }.to_json
      )
    end
    
    Postage.log.info "Received Response [UID: #{self.uid}] \n#{self.response.inspect}\n"
    
    Postage::Response.new(self.response)
    
  rescue Timeout::Error, SocketError, Exception => e
    Postage.log.error "Failure [UID: #{self.uid}] \n#{e.inspect}"
    nil # no response generated
  end
  
end
