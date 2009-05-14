module PostageMailer
  
  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      class << self
        alias_method_chain :method_missing, :postage
      end
    end
  end
  
  
  # >> Class Methods -----------------------------------------------------
  module ClassMethods
    
    def method_missing_with_postage(method_symbol, *parameters) 
      if match = /^carry_([_a-z]\w*)/.match(method_symbol.to_s)
        carry(new(match[1], *parameters))
      else
        method_missing_without_postage(method_symbol, *parameters)
      end
    end


    def carry(mail)
      # Collect the headers
      header = {
        'Subject'   => mail.subject, 
        'From'      => mail.from
      } 
      mail.headers.each{ |k, v| header[k] = v }

      # Collect the parts
      parts = {}
      attachments = {}
      mail.parts.each do |part|
        case part.content_disposition
          when 'inline' 
            parts[part.content_type] = part.body
          when 'attachment'
            attachments[part.filename] = {:content_type => part.content_type, :content => part.body }
        end
      end
      parts[:attachments] = attachments unless attachments.blank?

      # Collect specific postage data or the recipient list if no postage data was specified
      postage_data = mail.postage_data.blank? ? mail.recipients : mail.postage_data

      # Send it all
      Postage.new.send_message(parts, postage_data, {}, header)
    end

  end


  # >> Instance Methods -----------------------------------------------------
  module InstanceMethods
    attr_writer :postage_data

    def postage_data
      @postage_data ||= { }
    end
  end
end