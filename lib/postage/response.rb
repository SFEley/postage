# Response that is retuned by PostageApp server. Normally, a hash is expected
# This is just a simple wrapper with some helper methods
#
class Postage::Response < HashWithIndifferentAccess
  
  def success?
    self[:response][:status].to_s == 'ok'
  rescue
    false
  end
  
  def error?
    !success?
  end
  
  # -- Logical partitions of the response -----------------------------------
  def response
    self[:response]
  end
  
  def api
    self[:api]
  end
  
  def data
    self[:data]
  end
  
end