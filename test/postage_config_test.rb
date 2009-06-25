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

  def test_mangled_config
    config_filename = File.join(RailsEnvironment.default.root, 'config', 'mangled-config.yml')
    
    config_file = open(config_filename)
    
    # Verify that mangled configuration file will not load properly
    exception = nil
    loaded = nil
    
    begin
      loaded = YAML.load(config_file)
    rescue => e
      exception = e
    end
    
    assert exception
    assert !loaded
    
    begin
      Postage::Config.file_path = config_filename
      
      # Force a reload of the configuration befrore using it
      Postage.config(true)
      
      assert_equal 'http://postageapp.com', Postage.config.url
      assert_equal 'INSERT_VALID_API_KEY_HERE', Postage.config.api_key
    ensure
      Postage::Config.file_path = nil
      Postage.config(true)
    end
  end
end
