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