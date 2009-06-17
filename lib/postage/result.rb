class Postage
  class Result
    def initialize(response)
      @response = response
    end
    
    def errors?
      @response['response'] == 'error'
    end
    
    def errors
      @response['error']
    end
    
    def api_key
      @response['api'] and @response['api']['api_key']
    end

    def api_version
      @response['api'] and @response['api']['version']
    end

    def transmission_id
      @response['transmission'] and @response['transmission']['id']
    end
    
    def transmission_href
      @response['transmission'] and @response['transmission']['href']
    end
    
    def to_h
      @response
    end
  end
end
