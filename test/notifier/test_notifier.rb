class TestNotifier < Postage::Mailer
  
  def blank
    # ...
  end
  
  def with_no_content
    setup_headers
  end
  
  def with_text_only_view
    setup_headers
    # ...
  end
  
  def with_html_and_text_views
    setup_headers
    # ...
  end
  
  def with_manual_parts
    setup_headers
    # ...
  end
  
  def with_custom_postage_variables
    setup_headers
    # ...
  end
  
private

  def setup_headers
    recipients 'test@test.test'
    from       'text@test.test'
    subject    'Test Email'
  end
  
end