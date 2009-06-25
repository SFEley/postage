require 'test_helper'

class PostageConfigTest < ActiveSupport::TestCase # :nodoc: all
  def test_configuration_presence
    assert Postage.config.exists?
  end
  
  def test_default_configuration
    assert_equal 'http://postageapp.test', Postage.config.url
    assert_equal 'TEST_API_KEY', Postage.config.api_key
  end

  def test_environment_loading
    config = Postage::Config.new('development')
    
    assert_equal 'http://postageapp.dev', config.url
    assert_equal 'DEVELOPMENT_API_KEY', config.api_key
  end
end
