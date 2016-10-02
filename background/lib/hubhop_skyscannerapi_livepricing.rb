module HubHop
  module SkyScannerAPI
    class LivePricing
      def initialize(log)
        @log = log
      end

      def create_session(from, to, date)
        begin
          api_response = live_prices_session from, to, date
          @log.debug "Got api response: #{api_response.inspect}"
          api_response['location']
        rescue Exception => e
          msg = e.message + "\n"
          e.backtrace.each do |x|
            msg += "        " + x + "\n"
          end
          msg += "=================================================="
          @log.error msg
          raise "Couldn't create search session"
        end
      end

      def poll_session(session_url)
        begin
          api_response = live_prices_results session_url
          @log.debug "Got api response: #{api_response.inspect}"
          api_response = JSON.parse(api_response)
          @log.debug "Parsed api response: #{api_response.inspect}"
          if !session_complete?(api_response)
            @log.info "Session is not yet complete on SkyScanner's side"
            return false 
          end
          distill_session api_response
        rescue Exception => e
          msg = e.message + "\n"
          e.backtrace.each do |x|
            msg += "        " + x + "\n"
          end
          msg += "=================================================="
          @log.error msg
          raise "Couldn't poll a search session result"
        end
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

      def live_prices_session(from, to, date)
        uri = SkyScannerAPI::CREATE_PRICING_SESSION_ADDRESS
        params = {
          "apiKey" => ENV['API_KEY'], "country" => "RU",
          "currency" => "RUB", "locale" => "ru-RU",
          "originplace" => "#{from}-Iata",
          "destinationplace" => "#{to}-Iata",
          "outbounddate" => date
        }
        headers = {'Accept' => 'application/json'}

        i = 0
        while i < 10 do
          res = SkyScannerAPI::post uri, params, headers

          case res.code
          when '201'
            return res
          when '400', '403'
            raise "Bad request. #{res.code}. Body: #{res.body}"
          when '429', '500'
            @log.info "Re-running the request. #{res.code}. Body: #{res.body}"
            SkyScannerAPI::wait_a_bit i + 5
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
        while i < 10 do
          res = SkyScannerAPI::perform_request adr

          case res.code
          when '200'
            return res.body
          when '410'
            raise "Session expired"
          when '400', '403'
            raise "Bad request. #{res.code}. Body: #{res.body}"
          when '204', '429', '500'
            @log.info "Re-running the request. #{res.code}. Body: #{res.body}"
            SkyScannerAPI::wait_a_bit i + 5
            i += 1
          when '304'
            @log.info "Got 304 (not changed). Re-running the request. #{res.code}. Body: #{res.body}"
            SkyScannerAPI::wait_a_bit i + 5
            i += 1
          end
        end

        raise "Can't retrieve data for session_url: #{session_url}"
      end
    end
  end
end
