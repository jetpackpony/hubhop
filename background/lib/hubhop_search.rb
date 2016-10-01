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
      HubHop::logger.info "Start search for request_id: '#{request_id}'"
      @req_id = request_id
      setup
      process
      complete
      HubHop::logger.info "Complete search for request_id: '#{request_id}'"
    end

    private

    def setup
      HubHop::logger.info "Loading request data"
      data = redis.get("#{@req_id}:request")
      HubHop::logger.debug "Loaded request data: '#{data}'"
      begin
        @input = JSON.parse(data, symbolize_names: true)[:request_data]
        @input['request_id'] = @req_id
        HubHop::logger.debug "Parsed loaded data: '#{@input.inspect}'"
      rescue => err
        msg = "Failed to parse the request data in the DB\nMessage: #{err.message}"
        HubHop::logger.fatal msg
        raise msg
      end
    end

    def process
      HubHop::logger.info "Start processing request"
      flight_data = json_parse(
        redis.get "#{@req_id}:collected_flights"
      )
      if flight_data.nil?
        HubHop::logger.info "Flight data not yet collected"
        HubHop::logger.info "Starting Collector"
        flight_data = HubHop::Collector.new(@input).collect
        HubHop::logger.info "Collecting flight data complete"
        HubHop::logger.debug "Collected flight data: #{flight_data.inspect}"
        redis.set "#{@req_id}:collected_flights", flight_data.to_json
      else
        HubHop::logger.info "Flight data already collected, loaded from DB"
        HubHop::logger.debug "Collected flight data: #{flight_data.inspect}"
      end
      HubHop::logger.info "Start building flight graph"
      @cheapest = HubHop::FlightGraph.new(
        flight_data.select { |x| x.is_a? Hash },
        @input[:from_place],
        @input[:to_place],
        @input[:max_transit_time]
      ).cheapest
      HubHop::logger.debug "Cheapest flight found: #{@cheapest.inspect}"
    end

    def complete
      HubHop::logger.info "Complete processing request. Writing result to DB"
      redis.set "#{@req_id}:completed", "true"
      redis.set "#{@req_id}:results", { cheapest_option: @cheapest }.to_json
    end

    def json_parse(json)
      HubHop::logger.info "Parsing collected data in the DB"
      HubHop::logger.debug "Data to parse: #{json}"
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
        HubHop::logger.info "Couldn't parse data in the DB"
        nil
      end
    end
  end
end
