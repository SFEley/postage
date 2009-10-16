require File.dirname(__FILE__) + '/test_helper'

class PostageTest < Test::Unit::TestCase
  
  def test_config
    Postage.configure do |config|
      config.api_key            = '1234567890abcdef'
      config.url                = 'http://api.postageapp.local'
      config.recipient_override = 'oleg@twg.test'
      config.environments       = [:production, :staging]
    end
    
    assert_equal '1234567890abcdef', Postage.api_key
    assert_equal 'http://api.postageapp.local', Postage.url
    assert_equal 'oleg@twg.test', Postage.recipient_override
    assert_equal [:production, :staging], Postage.environments
  end
  
end
