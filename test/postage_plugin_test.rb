require 'test_helper'

class PostagePluginTest < ActiveSupport::TestCase
  def test_read_configuration
    assert Postage.config.exist?
  end
end
