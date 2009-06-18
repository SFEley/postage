# These methods are imported into ActionMailer::Base by init.rb

class Postage
  module Mailer
    # == Include Hook =======================================================

    def self.included(base)
      base.send(:include, InstanceMethods)
    end
  
    # == Instance Methods ===================================================

    module InstanceMethods
      def perform_delivery_postage(mail)
        arguments = {
          :headers => {
            'Subject' => self.subject, 
            'From' => self.from
          }.merge(self.headers),
          :parts => { }
        }

        # Collect the parts
        if (self.parts.blank?)
          arguments[:parts][self.content_type] = self.body
        else
          self.parts.each do |part|
            case (part.content_disposition)
            when 'inline'
              arguments[:parts][part.content_type] = part.body
            when 'attachment'
              require 'base64'

              arguments[:parts][:attachments] ||= { }
              arguments[:parts][:attachments][part.filename] = {
                :content_type => part.content_type,
                :content => Base64.encode64(part.body)
              }
            end
          end
        end
        
        Postage.end_message(
          arguments[:parts],
          self.recipients,
          { },
          arguments[:headers]
        )
      end
    end
  end
end
