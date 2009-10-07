class Postage::Response < HashWithIndifferentAccess
  
  def error?
    self[:response].to_s == 'error'
  end
  
  def success?
    self[:response].to_s == 'success'
  end
  
end