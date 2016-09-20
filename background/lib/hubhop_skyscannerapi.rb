require 'json'
require 'net/http'
require_relative "./hubhop_skyscannerapi_constants"
require_relative "./hubhop_skyscannerapi_livepricing"
require_relative "./hubhop_skyscannerapi_browsecache"

module HubHop
  module SkyScannerAPI
    include HubHop::SkyScannerAPI::Constants

    def self.wait_a_bit(order)
      sleep(order + 1)
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
  end
end
