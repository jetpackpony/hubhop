require 'dotenv'
require 'sidekiq'
Dotenv.load

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

module HubHop
  class Search
    include Sidekiq::Worker
    attr_reader :input

    def perform(request_id)
      @req_id = request_id
      @input = {}
      puts "test from #{@req_id}"
      #setup
      #process
      #complete
    end

    private

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
      HubHop.redis.set "#{@req_id}:results", { results: true }.to_json
    end
  end
end
