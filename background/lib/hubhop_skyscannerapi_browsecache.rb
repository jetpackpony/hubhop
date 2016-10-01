module HubHop
  module SkyScannerAPI
    class BrowseCache

      def initialize(log)
        @log = log
      end

      def get_cached_quote(from, to, date)
        begin
          api_response = browse_quotes from, to, date
        rescue Exception => e
          @log.error e.message
          return []
        end
        @log.info "For #{from}->#{to}@#{date} got data: #{api_response}"
        distill JSON.parse(api_response)
      end

      def distill(json)
        return [] if json["Quotes"].count == 0
        quote = json["Quotes"].sort { |a, b| a["MinPrice"] <=> b["MinPrice"] }[0]
        [{
          from: get_from(json["Places"], quote["OutboundLeg"]),
          to: get_to(json["Places"], quote["OutboundLeg"]),
          date: Date.parse(quote["OutboundLeg"]["DepartureDate"]),
          price: quote["MinPrice"].ceil
        }]
      end

      def get_from(places, leg)
        places.select do |x|
          x["PlaceId"] == leg["OriginId"]
        end.
          first["IataCode"]
      end

      def get_to(places, leg)
        places.select do |x|
          x["PlaceId"] == leg["DestinationId"]
        end.
          first["IataCode"]
      end

      def browse_quotes(from, to, date)
        adr = "" + SkyScannerAPI::BROWSE_CACHE_ADDRESS
        adr << "/ru/RUB/ru-RU"
        adr << "/#{from}-Iata"
        adr << "/#{to}-Iata"
        adr << "/#{date}"
        adr << "?apiKey=#{ENV['API_KEY']}"

        i = 0
        while i < 5 do
          res = SkyScannerAPI::perform_request adr

          case res.code
          when '200'
            return res.body
          when '400', '403'
            raise "Bad request. #{res.code}. Body: #{res.body}"
          when '429', '500'
            SkyScannerAPI::wait_a_bit i
            i += 1
          end
        end

        raise "Can't retrieve data for from:#{from}, to:#{to}, date:#{date}"
      end

    end
  end
end
