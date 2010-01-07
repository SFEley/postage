require 'action_mailer'

# Postage::Mailer allows you to use/re-use existing mailers set up using
# ActionMailer. The only catch is to change inheritance from ActionMailer::Base
# to Postage::Mailer
#
# Here's an example of a valid Postage::Mailer class
# 
#   class Notifier < Postage::Mailer
#     def signup_notification(recipient)
#       recipients  recipient.email_address
#       from        'system@example.com'
#       subject     'New Account Information'
#     end
#   end
#
# Postage::Mailer introduces a few mailer methods specific to Postage:
#
# * postage_template  - template name that is defined in your PostageApp project
# * postage_variables - extra variables you want to send along with the message
#
# Sending email
#
#   Notifier.deliver_signup_notification(user) # contacts PostageApp and returns Postage::Response
#   request = Notifier.create_signup_notification(user) # creates Postage::Request object
#
class Postage::Mailer < ActionMailer::Base
  
  require 'base64'
  
  self.delivery_method = :postage # unless Rails.env.test?
  
  # adv_attr_accessor :postage_template
  # adv_attr_accessor :postage_variables
  
  def perform_delivery_postage
    # ...
  end
  
  
  # Creating a Postage::Request object unlike TMail one in ActionMailer::Base
  def create_mail
    params = { }
    params[:recipients] = self.recipients unless self.recipients.blank?
    
    params[:headers] = { }
    params[:headers][:subject]  = self.subject  unless self.subject.blank?
    params[:headers][:from]     = self.from     unless self.from.blank?
    params[:headers].merge!(self.headers)       unless self.headers.blank?
    
    params[:content] = { }
    params[:attachments] = { }
    
    if @parts.empty?
      params[:content][self.content_type] = self.body unless self.body.blank?
    else
      self.parts.each do |part|
        case part.content_disposition
        when 'inline'
          params[:content][part.content_type] = part.body
        when 'attachment'
          params[:attachments][part.filename] = {
            :content_type => part.content_type,
            :content      => Base64.encode64(part.body)
          }
        end
      end
    end
    
    # api_params[:template] = postageapp_template unless postageapp_template.blank?
    # api_params[:variables] = postageapp_variables unless postageapp_variables.blank?
    
    params.delete(:headers)     if params[:headers].blank?
    params.delete(:content)     if params[:content].blank?
    params.delete(:attachments) if params[:attachments].blank?
    
    @mail = Postage::Request.new(:send_message, params)
  end
  
  # Not insisting rendering a view if it's not there. Postage can send blank content
  # provided that the template is defined.
  def render(opts)
    super(opts)
  rescue ActionView::MissingTemplate
    # do nothing
  end
  
end