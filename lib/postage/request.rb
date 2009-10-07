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
    'X-Postage-Client-Version' => Postage::VERSION
  }
  
  attr_accessor :api_method,
                :arguments,
                :response
  
  def initialize(api_method, arguments = {})
    @api_method = api_method
    @arguments  = arguments || {}
  end
  
  def call_url
    "#{Postage.url}/api/#{Postage.api_key}/#{self.api_method}.json"
  end
  
  def uid
    @uid ||= Time.now.to_f.to_s
  end
  
  def call!
    Postage.log.info "Sending Request [UID: #{self.uid} URL: #{call_url}] \n#{self.arguments.inspect}\n"
    
    self.arguments[:uid]              = self.uid
    self.arguments[:plugin_version]   = Postage::VERSION
    
    unless Postage.recipient_override.blank?
      self.arguments[:recipient_override] = Postage.recipient_override
    end
    
    Timeout::timeout(2) do
      self.response = self.class.post( call_url, 
        :headers  => HEADERS,
        :body     => { :arguments => self.arguments }.to_json
      )
    end
    
    Postage.log.info "Received Response [UID: #{self.uid}] \n#{self.response.inspect}\n"
    
    HashWithIndifferentAccess.new(self.response)
    
  rescue Timeout::Error, SocketError, Exception => e
    Postage.log.error "Failure [UID: #{self.uid}] \n#{e.inspect}"
    nil # no response generated
  end
  
end
