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
      puts "performed request #{request_id}"
=begin
      @req_id = request_id
      setup
      process
      complete
=end
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
      flight_data = json_parse(
        redis.get "#{@req_id}:collected_flights"
      )
      if flight_data.nil?
        flight_data = HubHop::Collector.new(@input).collect
        redis.set "#{@req_id}:collected_flights", flight_data.to_json
      end
      @cheapest = HubHop::FlightGraph.new(
        flight_data.select { |x| x.is_a? Hash },
        @input[:from_place],
        @input[:to_place],
        @input[:max_transit_time]
      ).cheapest
    end

    def complete
      redis.set "#{@req_id}:completed", "true"
      redis.set "#{@req_id}:results", { cheapest_option: @cheapest }.to_json
    end

    def json_parse(json)
      begin
        JSON.parse(
          json,
          :symbolize_keys => true
        ).map { |x| (x.is_a? Hash) ? x.deep_symbolize_keys : x }.
          map do |x|
            if x.is_a? Hash
              x[:departure] = DateTime.parse(x[:departure])
              x[:arrival] = DateTime.parse(x[:arrival])
            end
            x
          end
      rescue
        nil
      end
    end
  end
end
