require 'json'
require 'net/http'
require_relative "./hubhop_skyscannerapi_constants"

module HubHop
  module SkyScannerAPI
    include HubHop::SkyScannerAPI::Constants

    def self.create_session(from, to, date)
      begin
        api_response = live_prices_session from, to, date
        api_response['location']
      rescue Exception => e
        log e.message
        raise "Couldn't create a search session"
      end
    end

    def self.poll_session(session_url)
      api_response = JSON.parse(live_prices_results session_url)
      return false if !session_complete?(api_response)
      distill_session api_response
    end

    def self.get_cached_quote(from, to, date)
      begin
        api_response = browse_quotes from, to, date
      rescue Exception => e
        log e.message
        return []
      end
      log "For #{from}->#{to}@#{date} got data: #{api_response}"
      distill JSON.parse(api_response)
    end

    private

    def self.session_complete?(api_response)
      api_response["Status"] == "UpdatesComplete"
    end

    def self.distill_session(data)
      res = []
      data["Itineraries"].each do |leg|
        tmp = {}
        price = leg["PricingOptions"].
          sort { |a,b| a["Price"] <=> b["Price"]}.
          first
        tmp[:price] = price["Price"]
        tmp[:deeplink] = price["DeeplinkUrl"]
        tmp[:agent] = {
          name: get_agent(price["Agents"][0], data)["Name"]
        }
        tmp[:from] = {
          code: get_place(
            get_leg(leg["OutboundLegId"], data)["OriginStation"], data
          )["Code"]
        }
        tmp[:to] = {
          code: get_place(
            get_leg(leg["OutboundLegId"], data)["DestinationStation"], data
          )["Code"]
        }
        tmp[:carrier] = {
          name: get_carrier(
            get_leg(leg["OutboundLegId"], data)["Carriers"][0], data
          )["Name"]
        }
        tmp[:departure] = DateTime.parse(
          get_leg(leg["OutboundLegId"], data)["Departure"])
        tmp[:arrival] = DateTime.parse(
          get_leg(leg["OutboundLegId"], data)["Arrival"])

        res.push tmp
      end
      res

    end

    def self.get_agent(id, data)
      data["Agents"].find { |x| x["Id"] == id }
    end

    def self.get_place(id, data)
      data["Places"].find { |x| x["Id"] == id }
    end

    def self.get_leg(id, data)
      data["Legs"].find { |x| x["Id"] == id }
    end

    def self.get_carrier(id, data)
      data["Carriers"].find { |x| x["Id"] == id }
    end

    def self.log(str)
      HubHop::Log.log str
    end

    def self.distill(json)
      return [] if json["Quotes"].count == 0
      quote = json["Quotes"].sort { |a, b| a["MinPrice"] <=> b["MinPrice"] }[0]
      [{
        from: get_from(json["Places"], quote["OutboundLeg"]),
        to: get_to(json["Places"], quote["OutboundLeg"]),
        date: Date.parse(quote["OutboundLeg"]["DepartureDate"]),
        price: quote["MinPrice"].ceil
      }]
    end

    def self.get_from(places, leg)
      places.select do |x|
        x["PlaceId"] == leg["OriginId"]
      end.
        first["IataCode"]
    end

    def self.get_to(places, leg)
      places.select do |x|
        x["PlaceId"] == leg["DestinationId"]
      end.
        first["IataCode"]
    end

    def self.browse_quotes(from, to, date)
      adr = "" + BROWSE_CACHE_ADDRESS
      adr << "/ru/RUB/ru-RU"
      adr << "/#{from}-Iata"
      adr << "/#{to}-Iata"
      adr << "/#{date}"
      adr << "?apiKey=#{ENV['API_KEY']}"

      i = 0
      while i < 5 do
        res = perform_request URI(adr)

        case res.code
        when '200'
          return res.body
        when '400', '403'
          raise "Bad request. #{res.code}. Body: #{res.body}"
        when '429', '500'
          wait_a_bit i
          i += 1
        end
      end

      raise "Can't retrieve data for from:#{from}, to:#{to}, date:#{date}"
    end

    def self.live_prices_session(from, to, date)
      uri = URI(CREATE_PRICING_SESSION_ADDRESS)
      params = {
        "apiKey" => ENV['API_KEY'], "country" => "RU",
        "currency" => "RUB", "locale" => "ru-RU",
        "originplace" => "#{from}-Iata",
        "destinationplace" => "#{to}-Iata",
        "outbounddate" => date
      }
      headers = {'Accept' => 'application/json'}

      i = 0
      while i < 5 do
        res = post uri, params, headers

        case res.code
        when '201'
          return res
        when '400', '403'
          raise "Bad request. #{res.code}. Body: #{res.body}"
        when '429', '500'
          wait_a_bit i
          i += 1
        end
      end

      raise "Can't retrieve data for from:#{from}, to:#{to}, date:#{date}"
    end

    def self.live_prices_results(session_url)
      adr = "" + session_url
      adr << "?apiKey=#{ENV['API_KEY']}"
      adr << "&stops=0"

      #adr << "&pageindex=0"
      #adr << "&pagesize=3"

      i = 0
      while i < 5 do
        res = perform_request URI(adr)

        case res.code
        when '200', '304'
          return res.body
        when '410'
          raise "Session expired"
        when '400', '403'
          raise "Bad request. #{res.code}. Body: #{res.body}"
        when '204', '429', '500'
          wait_a_bit i
          i += 1
        end
      end

      raise "Can't retrieve data for from:#{from}, to:#{to}, date:#{date}"
    end
    def self.perform_request(uri)
      req = Net::HTTP::Get.new(uri)
      req['Accept'] = "application/json"
      req['X-Forwarded-For'] = "95.27.71.139"

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end

    def self.post(uri, parameters, headers)
      req = Net::HTTP::Post.new(uri)
      req.set_form_data parameters
      headers.each do |key, val|
        req[key] = val
      end

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end


    def self.wait_a_bit(order)
      sleep(order + 1)
    end
  end
end
