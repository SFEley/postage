# This tests runs against real postageapp deployment, thus make sure it's accessible
# You can put your project's API key and real production url 'api.postageapp.com'

require File.dirname(__FILE__) + '/../test_helper'

class RequestTest < Test::Unit::TestCase
  
  def setup
    Postage.configure do |config|
      config.api_key            = '1234567890abcdef'
      config.api_version        = '1.0'
      config.url                = 'http://api.postageapp.local'
      config.recipient_override = 'oleg@twg.test'
      config.environments       = [:production, :staging]
    end
  end
  
  def test_request_setup  
    r = Postage::Request.new(:send_message, message_params)
    assert_equal :send_message, r.api_method
    assert_equal 'http://api.postageapp.local/v.1.0/send_message.json', r.call_url
    assert !r.arguments.blank?
    assert !r.uid.blank?
  end
  
  def test_request_call
    r = Postage::Request.new(:send_message, message_params)
    response = r.call!
    assert response.success?
    assert_equal 'ok', response[:response][:status]
    assert_equal r.uid, response[:response][:uid]
    assert !response[:data][:message][:id].blank?
  end
  
  def test_request_call_failure
    r = Postage::Request.new(:send_message, message_params(:message => nil))
    response = r.call!
    assert response.error?
    assert_equal 'bad_request', response[:response][:status]
    assert_equal r.uid, response[:response][:uid]
    assert_equal 'Message content or message template must be provided', response[:data][:message][:error]
  end
  
  def test_request_call_timeout
    Postage.url = 'http://not_valid_site.test'
    r = Postage::Request.new(:send_message, message_params(:message => nil))
    response = r.call!
    assert !response
  end
  
protected

  def message_params(options = {})
    { :message    => { 'text/plain' => 'plain text message',
                       'text/html'  => 'html text message' },
      :recipients => 'oleg@twg.test' }.merge(options)
  end
  
end
