ENV['RAILS_ENV'] = 'test'

require File.expand_path(File.dirname(__FILE__) + "/rails_root/config/environment")
require 'test_help'

require 'redgreen' unless ENV['TM_FILEPATH']

Postage::Mailer.template_root = Rails.root.join('..', 'notifier')
#raise Postage::Mailer.template_root.to_s

class ActiveSupport::TestCase
  
  # Most of the tests are hitting actual PostageApp application
  # Thus we need configuration that works
  def setup
    # resetting postage configs
    Postage.configure do |config|
      config.api_key            = '1234567890abcdef'
      config.url                = 'http://api.postageapp.local'
      config.recipient_override = 'oleg@twg.test'
    end
  end
  
end