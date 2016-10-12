require 'json'
require 'net/http'
require_relative "./hubhop_skyscannerapi_constants"
require_relative "./hubhop_skyscannerapi_livepricing"
require_relative "./hubhop_skyscannerapi_browsecache"
require_relative "./throttle"

module HubHop
  module SkyScannerAPI
    include HubHop::SkyScannerAPI::Constants
    CREATE_SESSION_LIMIT = 15
    POLL_SESSION_LIMIT = 50
    REQUEST_LIMIT_DELAY = 60
    @@throttle_post = Throttle.new CREATE_SESSION_LIMIT, REQUEST_LIMIT_DELAY
    @@throttle_get = Throttle.new POLL_SESSION_LIMIT, REQUEST_LIMIT_DELAY

    def self.wait_a_bit(order)
      sleep(order + 1)
    end

    def self.perform_request(uri)
      uri = URI(uri)
      req = Net::HTTP::Get.new(uri)
      req['Accept'] = "application/json"
      req['X-Forwarded-For'] = "95.27.71.139"

      @@throttle_get.delay do
        send_request(uri, req)
      end
    end

    def self.post(uri, parameters, headers)
      uri = URI(uri)
      req = Net::HTTP::Post.new(uri)
      req.set_form_data parameters
      headers.each do |key, val|
        req[key] = val
      end

      @@throttle_post.delay do
        send_request(uri, req)
      end
    end

    def self.send_request(uri, req)
      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end
  end
end
