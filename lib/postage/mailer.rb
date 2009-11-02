# When you wish to use existing ActionMailer setup just insert the following
# line in your environment.rb file
# 
#   config.action_mailer.delivery_method = :postage
#
# Now all emails will be send with postage plugin instead of smtp server

require 'base64'

module Postage::Mailer
  
  def self.included(base)
    Postage.log.info 'Preparing ActiveMailer to use postage delivery method'
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    
    def perform_delivery_postage(mail)
      
      arguments = {
        :headers => {
          'Subject' => self.subject, 
          'From'    => self.from
        }.merge(self.headers),
        :parts => { }
      }
      
      # Collect the parts
      if self.parts.blank?
        arguments[:parts][self.content_type] = self.body
      else
        self.parts.each do |part|
          case part.content_disposition
          when 'inline'
            arguments[:parts][part.content_type] = part.body
          when 'attachment'
            arguments[:parts][:attachments] ||= { }
            arguments[:parts][:attachments][part.filename] = {
              :content_type => part.content_type,
              :content      => Base64.encode64(part.body)
            }
          end
        end
      end
      
      Postage.send_message(
        arguments[:parts],
        self.recipients,
        { },
        arguments[:headers]
      )
      
    rescue => e
      Postage.log.info "Failed to perform delivery with postage: \n#{e.inspect}"
      raise e
    end
  end
end

# Overriding the default ActionMailer deliver! method
class ActionMailer::Base
  def deliver!(mail = @mail)
    raise "no mail object available for delivery!" unless mail
    unless logger.nil?
      logger.info  "Sent mail to #{Array(recipients).join(', ')}"
      logger.debug "\n#{mail.encoded}"
    end
  
    response = nil
    begin
      response = __send__("perform_delivery_#{delivery_method}", mail) if perform_deliveries
    rescue Exception => e  # Net::SMTP errors or sendmail pipe errors
      raise e if raise_delivery_errors
    end
  
    return(delivery_method == :postage ? response : mail)
  end
end