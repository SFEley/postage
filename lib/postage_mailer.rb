module PostageMailer
  
  def self.included(base)
    base.send(:include, InstanceMethods)
  end
  
  # >> Instance Methods -----------------------------------------------------
  module InstanceMethods

    def perform_delivery_postage(mail)
      # Collect the headers
      header = {
        'Subject'   => self.subject, 
        'From'      => self.from
      } 
      self.headers.each{ |k, v| header[k] = v }

      # Collect the parts
      parts = {}
      attachments = {}
      self.parts.each do |part|
        case part.content_disposition
          when 'inline' 
            parts[part.content_type] = part.body
          when 'attachment'
            attachments[part.filename] = {:content_type => part.content_type, :content => part.body }
        end
      end
      parts[:attachments] = attachments unless attachments.blank?

      # Send it all
      Postage.new.send_message(parts, self.recipients, {}, header)
    end

  end
end