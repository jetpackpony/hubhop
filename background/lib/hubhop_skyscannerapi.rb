require 'json'

module HubHop
  class SkyScannerAPI
    SKYSCANNER_API = "http://partners.api.skyscanner.net/apiservices"
    BROWSE_CACHE_ADDRESS = "#{SKYSCANNER_API}/browsequotes/v1.0"

    def self.create_session(from, to, date)

    end

    def self.poll_session(session_id)
    end

    def self.get_cached_quote(from, to, date)
      distill JSON.parse(browse_quotes from, to, date)
    end

    private

    def self.distill(json)
      quote = json["Quotes"].sort { |a, b| a["MinPrice"] <=> b["MinPrice"] }[0]
      {
        from: get_from(json["Places"], quote["OutboundLeg"]),
        to: get_to(json["Places"], quote["OutboundLeg"]),
        date: Date.parse(quote["OutboundLeg"]["DepartureDate"]),
        price: quote["MinPrice"].ceil
      }
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
      adr = BROWSE_CACHE_ADDRESS
      adr << "/ru/RUB/ru-RU"
      adr << "/#{from}-Iata"
      adr << "/#{to}-Iata"
      adr << "/#{date}"
      adr << "?apiKey=#{ENV['API_KEY']}"

      uri = URI(adr)

      req = Net::HTTP::Get.new(uri)
      req['Accept'] = "application/json"
      req['X-Forwarded-For'] = "95.27.71.139"

      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(req)
      }

      res.body if res.is_a?(Net::HTTPSuccess)
    end
  end
end
