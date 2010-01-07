require File.dirname(__FILE__) + '/../test_helper'

class MailerTest < ActiveSupport::TestCase
  
  def test_create_blank
    assert request = TestNotifier.create_blank
    assert_equal :send_message, request.api_method
    assert_equal 'http://api.postageapp.local/v.1.0/send_message.json', request.call_url
    assert request.arguments.blank?
  end
  
  def test_deliver_blank
    # ...
  end
  
  def test_create_with_no_content
    assert request = TestNotifier.create_with_no_content
    assert_equal 'test@test.test', request.arguments[:recipients]
    assert_equal ({:from=>"text@test.test", :subject=>"Test Email"}), request.arguments[:headers]
    assert request.arguments[:content].blank?
  end
  
  def test_deliver_with_no_content
    # ...
  end
  
  def test_create_with_text_only_view
    assert request = TestNotifier.create_with_text_only_view
    raise request.to_yaml
    assert_equal '', request.arguments[:content]
  end
  
  def test_deliver_with_text_only_view
    # ...
  end
  
  def test_create_with_html_and_text_views
    assert request = TestNotifier.create_with_html_and_text_views
    raise request.to_yaml
  end
  
  def test_deliver_with_html_and_text_views
    # ...
  end
  
  def test_create_with_manual_parts
    # ...
  end
  
  def test_deliver_with_manual_parts
    # ...
  end
  
  def test_create_with_custom_postage_variables
    # ...
  end
  
  def test_deliver_with_custom_postage_variables
    # ...
  end
  
end