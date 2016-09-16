require 'pry'

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

module HubHop
  class Search
    include Sidekiq::Worker
    include HubHop::RedisConnect
    sidekiq_options :retry => false

    def perform(request_id)
      @req_id = request_id
      setup
      process
      complete
    end

    private

    def setup
      data = redis.get("#{@req_id}:request")
      begin
        @input = JSON.parse(data, symbolize_names: true)[:request_data]
        @input['request_id'] = @req_id
      rescue Exception => msg
        raise "Failed to parse the request data in the DB\nMessage: " + msg.message
      end
    end

    def process
      flight_data = HubHop::Collector.new(@input).collect
      redis.set "#{@req_id}:collected_flights", flight_data.to_json
      @cheapest = HubHop::FlightGraph.new(
        flight_data, @input[:from_place], @input[:to_place], @input[:max_transit_time]
      ).cheapest
    end

    def complete
      redis.set "#{@req_id}:completed", "true"
      redis.set "#{@req_id}:results", { cheapest_option: @cheapest }.to_json
    end
  end
end
