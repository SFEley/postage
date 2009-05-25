module PostageMailer
  
  def self.included(base)
    base.send(:include, InstanceMethods)
  end
  
  # >> Instance Methods -----------------------------------------------------
  module InstanceMethods

    def perform_delivery_postage(mail)      
      require "base64"

      # Collect the headers
      header = {
        'Subject'   => self.subject, 
        'From'      => self.from
      } 
      self.headers.each{ |k, v| header[k] = v }

      # Collect the parts
      parts = {}
      attachments = {}

      if self.parts.blank?
        parts[self.content_type] = self.body
      else
        self.parts.each do |part|
          case part.content_disposition
            when 'inline'
              parts[self.content_type] = part.body
            when 'attachment'
              attachments[part.filename] = {
                'filename' => part.filename,
                'content_type' => part.content_type, 
                'content' => Base64.encode64(part.body)
              }
          end
        end
      end

      parts[:attachments] = attachments unless attachments.blank?

      # Send it all
      Postage.new.send_message(parts, self.recipients, {}, header)
    end

  end
end