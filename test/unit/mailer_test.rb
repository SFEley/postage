require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../test_notifier'

class MailerTest < Test::Unit::TestCase
  
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
    assert_equal 'text only: plain text', request.arguments[:content]['text/plain']
  end
  
  def test_deliver_with_text_only_view
    # ...
  end
  
  def test_create_with_html_and_text_views
    assert request = TestNotifier.create_with_html_and_text_views
    assert_equal 'html and text: plain text', request.arguments[:content]['text/plain']
    assert_equal 'html and text: html', request.arguments[:content]['text/html']
  end
  
  def test_deliver_with_html_and_text_views
    # ...
  end
  
  def test_create_with_simple_view
    assert request = TestNotifier.create_with_simple_view
    assert_equal 'simple view content', request.arguments[:content]['text/plain']
  end
  
  def teste_deliver_with_simple_view
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