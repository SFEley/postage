class Postage::Response < HashWithIndifferentAccess
  
  def success?
    self[:response][:status].to_s == 'ok'
  rescue
    false
  end
  
  def error?
    !success?
  end
  
  def data
    self[:data]
  end
  
end