require 'dotenv'
require 'sidekiq'
Dotenv.load

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

module HubHop
  class Search
    include Sidekiq::Worker
    attr_reader :input, :redis

    def perform(request_id)
      @redis = Redis.new(db: ENV['REDIS_DB_NUMBER'])
      @req_id = request_id
      @input = {}
      setup
      process
      complete
    end

    def setup
      data = redis.get("#{@req_id}:request")
      begin
        @input = JSON.parse(data, symbolize_names: true)[:request_data]
      rescue Exception => msg
        raise "Failed to parse the request data in the DB\nMessage: " + msg.message
      end
    end

    def process
      flight_data = HubHop::Collector.new(@input).collect
      @cheapest = HubHop::Analyser.new(flight_data).get_cheapest
    end

    def complete
      redis.set "#{@req_id}:completed", "true"
      redis.set "#{@req_id}:results", { cheapest_option: @cheapest }.to_json
    end
  end
end
