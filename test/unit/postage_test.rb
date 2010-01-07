require File.dirname(__FILE__) + '/../test_helper'

class PostageTest < ActiveSupport::TestCase
  
  def test_default_config
    assert_equal '1234567890abcdef', Postage.api_key
    assert_equal 'http://api.postageapp.local', Postage.url
    assert_equal 'oleg@twg.test', Postage.recipient_override
    assert_equal ['send_message'], Postage.stored_failed_requests
    assert_equal Rails.root.join('tmp', 'stored_requests') , Postage.stored_failed_requests_path
  end
  
  def test_asetting_config
    Postage.configure do |c|
      c.api_key = 'new_api_key'
      c.url     = 'http://newurl.test'
    end
    
    assert_equal 'new_api_key', Postage.api_key
    assert_equal 'http://newurl.test', Postage.url
  end
  
  def test_call
    response = Postage.call(:get_account_info)
    assert response.success?
  end
  
end