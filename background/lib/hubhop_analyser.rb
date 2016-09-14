module HubHop
  class Analyser
    def initialize(form_input, flight_data)
      @input = form_input
      @flights = flight_data
      @graph = nil
    end

    def cheapest
      build_routes if !@graph
      @graph.cheapest
    end

    private

    def build_routes
      @graph = FlightGraph.new @flights, @input[:from_place], @input[:to_place], @input[:max_transit_time]
    end
  end
end

