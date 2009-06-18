class Postage
  class Request
    # == Constants ============================================================

    # == Extensions ===========================================================

    include HTTParty
    format :json

    # == Class Methods ========================================================
    
    def self.load(filename)
      new(*YAML.load(open(filename)))
    rescue => e
      # YAML or file-system related errors
    end

    # == Instance Methods =====================================================
    
    def initialize(api_call, arguments = { })
      @api_call = api_call
      @arguments = arguments
    end
    
    def unique_id
      @unique_id ||= Postage.generate_unique_id
    end
    
    def queue_file_name
      "%d.%s.%s.yaml" % [ Time.now.to_i, unique_id, @api_call ]
    end
    
    def error?
      !!@error
    end
    
    def error
      @error
    end
    
    def queued?
      !!@queued
    end
  
    def call_url
      @call_url ||=
        "#{Postage.config.url}/api/#{Postage.config.api_key}/#{@api_call}.#{Postage.config.api_format}"
    end

    def call!
      Rails.logger.debug("Postage [#{unique_id}] API call to #{call_url}")
      
      @error = nil

      @response = post!

      if (@response.error?)
        @error ||= "Error: #{response.error}"

        Rails.logger.debug("Postage [#{unique_id}] #{call_url} #{@error}")

        queue!
      else
        Rails.logger.debug("Postage [#{unique_id}] #{response.transmission_href or 'Success'}")
      end
  
      self
    end
    
    def response
      @response
    end
  
    def to_yaml
      [ @error ].compact.collect { |e| "# #{e}\n" }.to_s +
        [ @api_call, @arguments ].to_yaml
    end
  
    def post!
      Timeout::timeout(2) do
        Postage::Response.new(
          self.class.post(
            call_url,
            :headers => {
              'Content-Type' => "application/json"
            },
            :body => { :arguments => @arguments }.to_json
          )
        )
      end
    rescue HTTParty::Parsers::JSON::ParseError, Timeout::Error, SocketError, Exception => e
      error_message = "#{e.class} (#{e})"
      @error = "Exception: #{error_message}"
    
      Postage::Response.new(
        :response => 'error',
        :error => error_message
      )
    end

  protected
    def queue!
      Postage.queue!(queue_file_name) do |queued|
        queued.write(to_yaml)
      end

      @queued = true
    end
  end
end
