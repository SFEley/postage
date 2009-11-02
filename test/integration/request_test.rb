require File.dirname(__FILE__) + '/../test_helper'

class RequestTest < Test::Unit::TestCase
  
  def setup
    super
    # This tests runs against real postageapp deployment, thus make sure it's accessible
    # You can put your project's API key and real production url 'api.postageapp.com'
    #   Postage.url     = 'api.postageapp.com'
    #   Postage.api_key = 'your_api_key'
  end
  
  def test_request_setup  
    r = Postage::Request.new(:get_method_list)
    assert_equal :get_method_list, r.api_method
    assert_equal 'http://api.postageapp.local/v.1.0/get_method_list.json', r.call_url
    assert !r.uid.blank?
  end
  
  def test_request_call
    r = Postage::Request.new(:get_method_list)
    response = r.call!
    assert response.success?
    assert_equal 'ok', response[:response][:status]
    assert_equal r.uid, response[:response][:uid]
    assert !response.data.blank?
  end
  
  def test_request_call_failure
    r = Postage::Request.new(:get_method_that_does_not_exist)
    response = r.call!
    assert response.error?
    assert_equal 'internal_server_error', response[:response][:status]
    assert_equal r.uid, response[:response][:uid]
  end
  
  def test_request_call_timeout
    Postage.url = 'http://not_valid_site.test'
    r = Postage::Request.new(:get_method_list)
    response = r.call!
    assert !response
  end
  
end
