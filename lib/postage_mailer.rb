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
  
  module ClassMethods
    
    def method_missing_with_postage(method_symbol, *parameters) 
      if match = /^carry_([_a-z]\w*)/.match(method_symbol.to_s)
        carry(new(match[1], *parameters))
      else
        method_missing_without_postage(method_symbol, *parameters)
      end
    end


    def carry(mail)
      parts = {}
      mail.parts.each do |part|
        parts[part.content_type] = part.body
      end
      Postage.new.send_message(parts, mail.postage_data, {}, {:Subject => mail.subject, :From => mail.from})
    end
    
    
  end
  
  
  module InstanceMethods
    attr_accessor :postage_data
  end
end