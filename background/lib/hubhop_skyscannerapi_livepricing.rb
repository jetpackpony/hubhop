module HubHop
  module SkyScannerAPI
    class LivePricing
      def initialize(log)
        @log = log
      end

      def create_session(from, to, date)
        begin
          api_response = live_prices_session from, to, date
          api_response['location']
        rescue Exception => e
          log e.message
          raise "Couldn't create a search session"
        end
      end

      def poll_session(session_url)
        api_response = JSON.parse(live_prices_results session_url)
        return false if !session_complete?(api_response)
        distill_session api_response
      end

      def session_complete?(api_response)
        api_response["Status"] == "UpdatesComplete"
      end

      def distill_session(data)
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

      def get_agent(id, data)
        data["Agents"].find { |x| x["Id"] == id }
      end

      def get_place(id, data)
        data["Places"].find { |x| x["Id"] == id }
      end

      def get_leg(id, data)
        data["Legs"].find { |x| x["Id"] == id }
      end

      def get_carrier(id, data)
        data["Carriers"].find { |x| x["Id"] == id }
      end

      def log(str)
        @log.log str
      end

      def live_prices_session(from, to, date)
        uri = URI(SkyScannerAPI::CREATE_PRICING_SESSION_ADDRESS)
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
          res = SkyScannerAPI::post uri, params, headers

          case res.code
          when '201'
            return res
          when '400', '403'
            raise "Bad request. #{res.code}. Body: #{res.body}"
          when '429', '500'
            SkyScannerAPI::wait_a_bit i
            i += 1
          end
        end

        raise "Can't retrieve data for from:#{from}, to:#{to}, date:#{date}"
      end

      def live_prices_results(session_url)
        adr = "" + session_url
        adr << "?apiKey=#{ENV['API_KEY']}"
        adr << "&stops=0"

        #adr << "&pageindex=0"
        #adr << "&pagesize=3"

        i = 0
        while i < 5 do
          res = SkyScannerAPI::perform_request URI(adr)

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
    end
  end
end
