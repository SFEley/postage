class Postage
  class Response
    def initialize(response)
      @response = response
    end
    
    def error?
      @response['response'] == 'error'
    end
    
    def error
      @response['error'] and @response['error']['message']
    end

    def error_code
      @response['error'] and @response['error']['code']
    end
    
    def api_key
      @response['api'] and @response['api']['key']
    end

    def api_version
      @response['api'] and @response['api']['version']
    end
    
    def project?
      !!@response['project']
    end
    
    def project_name
      @response['project'] and @response['project']['name']
    end

    def project_href
      @response['project'] and @response['project']['href']
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
    
    def to_yaml
      @response.to_yaml
    end

    def to_json
      @response.to_json
    end
  end
end
