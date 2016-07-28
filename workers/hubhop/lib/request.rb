require 'sidekiq'

module HubHop
  class Request
    attr_reader :input

    def initialize(request_id)
      @req_id = request_id
      @input = {}
    end

    def run
      setup
      process
      complete
    end

    def setup
      HubHop.redis.set "#{@req_id}:completed", "false"
      data = HubHop.redis.get("#{@req_id}:request")
      begin
        @input = JSON.parse(data, symbolize_names: true)
      rescue Exception => msg
        raise "Failed to parse the request data in the DB\nMessage: " + msg.message
      end
    end

    def process
    end

    def complete
      HubHop.redis.set "#{@req_id}:completed", "true"
      #HubHop.redis.set "#{id}:results", { results: true }.to_json
    end
  end
end
