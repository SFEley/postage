module PostageMailer
  
  class Config
    @@recipients ||= []
    cattr_accessor :recipients
  end
  
  
  def self.included(base)
    base.send(:include, InstanceMethods)
  end
  
  # >> Instance Methods -----------------------------------------------------
  module InstanceMethods

    def perform_delivery_postage(mail)      
      require "base64"

      
      # Collect the headers
      postage = {
        :header => {
          'Subject'   => self.subject, 
          'From'      => self.from
        }.merge(self.headers),
        :parts => {},
      }

      # Collect the parts
      if self.parts.blank?
        postage[:parts][self.content_type] = self.body
      else
        self.parts.each do |part|
          case part.content_disposition
            when 'inline'
              postage[:parts][part.content_type] = part.body
            when 'attachment'
              postage[:parts][:attachments] ||= {}
              postage[:parts][:attachments][part.filename] = {
                :content_type => part.content_type, 
                :content      => Base64.encode64(part.body)
              }
          end
        end
      end
      
      # Check if we're overriding the recipients
      self.recipients = PostageMailer::Config.recipients unless PostageMailer::Config.recipients.empty?

      # Send it all
      Postage.new.send_message(postage[:parts], self.recipients, {}, postage[:header])
    end

  end
end