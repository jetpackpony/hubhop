require 'rgl/adjacency'
require 'rgl/dijkstra'

module HubHop
  class FlightGraph
    attr_reader :edges, :routes

    def initialize(flights, froms, tos, max_transit)
      @vertices = {}
      @edges = {}
      @routes = {}
      @max_transit = max_transit.to_i
      @graph = RGL::DirectedAdjacencyGraph.new
      @flights = Hash[(0..flights.size-1).zip flights]
      @froms, @tos = froms, tos
      load_flights @froms, @tos
      build_connections
      run_dijkstra
    end

    def cheapest
      routes.inject(routes.first[1]) do |res, (name,route)|
        res[:total_price] > route[:total_price] ? route : res
      end
    end

    def get_vertex(place, time, to_from)
      res = @vertices.find do |key, x|
        x[:place] == place && x[:time] == time && x[:to_from] == to_from
      end
      res ? res[1] : nil
    end

    def get_edge(from, to)
      return nil if (from = get_vertex(from[0], from[1], from[2])).nil?
      return nil if (to = get_vertex(to[0], to[1], to[2])).nil?
      res = @edges.find do |key, x|
        x[:from] == from[:id] && x[:to] == to[:id]
      end
      res ? res[1] : nil
    end

    def load_flights(froms, tos)
      vert_id = 0
      @flights.each do |flight_id, flight|
        # Find vertices if they exist or create new ones
        from_place = flight[:from][:code]
        from_time = (froms.include? from_place) ? false : flight[:departure]
        to_place = flight[:to][:code]
        to_time = (tos.include? to_place) ? false : flight[:arrival]

        vert_from = get_vertex from_place, from_time, :from
        if !vert_from
          vert_id = "From #{from_place} #{from_time ? from_time.strftime("%-d %b %Y %H:%M") : ''}"
          vert_from = {
            to_from: :from,
            id: vert_id,
            place: from_place,
            time: from_time,
            start: (froms.include? from_place),
            finish: false
          }
          @vertices[vert_id] = vert_from
          #vert_id += 1
        end
        vert_to = get_vertex to_place, to_time, :to
        if !vert_to
          vert_id = "To #{to_place} #{to_time ? to_time.strftime("%-d %b %Y %H:%M") : ''}"
          vert_to = {
            to_from: :to,
            id: vert_id,
            place: to_place,
            time: to_time,
            start: false,
            finish: (tos.include? to_place)
          }
          @vertices[vert_id] = vert_to
          #vert_id += 1
        end

        # Create edge
        edge = @edges[[vert_from[:id], vert_to[:id]]]
        if !edge
          @edges[[vert_from[:id], vert_to[:id]]] = {
            flight_id: flight_id,
            price: flight[:price],
            from: vert_from[:id],
            to: vert_to[:id],
            start: vert_from[:start],
            finish: vert_to[:finish]
          }
        else
          if edge[:price] > flight[:price]
            edge[:price] = flight[:price]
            edge[:flight_id] = flight_id
          end
        end

        # Add edge to the graph
        @graph.add_edge vert_from[:id], vert_to[:id]
      end
    end

    def build_connections
      connections = {}
      @edges.select { |key, x| !x[:finish] }.each do |key, arr|
        @edges.select { |key, x| !x[:start] }.each do |key1, dep|
          to = @vertices[arr[:to]]
          from = @vertices[dep[:from]]

          if to[:place] == from[:place]
            if from[:time] > (to[:time] + 2/24.0) &&
              from[:time] < (to[:time] + (@max_transit + 1)/24.0)
                connections[[to[:id], from[:id]]] = {
                  flight_id: false,
                  price: 0,
                  from: to[:id],
                  to: from[:id],
                  start: false,
                  finish: false
                }
                @graph.add_edge to[:id], from[:id]
            end
          end
        end
      end
      @edges.merge! connections
    end

    def run_dijkstra
      @routes = {}
      @froms.each do |from|
        from_vertex = get_vertex(from, false, :from)
        next if from_vertex.nil?
        @routes = @graph.
          dijkstra_shortest_paths(edges_map, from_vertex[:id]).
          select { |key, val| @tos.include? @vertices[key][:place] }.
          reject { |key, val| val.nil? }.
          inject(@routes) do |res, (to, route)|
            name = "#{from}->#{@vertices[to][:place]}"
            res[name] = expand route, name
            res
          end
      end
    end

    def edges_map
      @edges.inject({}) { |map, (k,v)| map[k] = v[:price]; map }
    end

    def expand(route, name)
      legs = []
      route.each_slice(2) do |leg|
        legs.push @flights[@edges[[leg[0], leg[1]]][:flight_id]]
      end
      {
        from: @vertices[route[0]][:place],
        to: @vertices[route[route.size-1]][:place],
        via: route.size > 2 ? @vertices[route[1]][:place] : "",
        name: name,
        legs: legs,
        total_price: legs.inject(0) { |sum, leg| sum += leg[:price] }
      }
    end
  end
end
