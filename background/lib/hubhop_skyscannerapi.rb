require 'json'
require 'net/http'
require_relative "./hubhop_skyscannerapi_constants"
require_relative "./hubhop_skyscannerapi_livepricing"
require_relative "./hubhop_skyscannerapi_browsecache"

module HubHop
  module SkyScannerAPI
    include HubHop::SkyScannerAPI::Constants
    CREATE_SESSION_LIMIT = 15
    POLL_SESSION_LIMIT = 50
    REQUEST_LIMIT_DELAY = 60
    @@mutex = Mutex.new
    @@create_requests = []
    @@poll_requests = []

    def self.wait_a_bit(order)
      sleep(order + 1)
    end

    def self.time_passed?(since, interval)
      Time.now - since > interval
    end

    def self.perform_request(uri)
      uri = URI(uri)
      req = Net::HTTP::Get.new(uri)
      req['Accept'] = "application/json"
      req['X-Forwarded-For'] = "95.27.71.139"

      if poll_requests_rate_limit_exeeded?
        wait_for_poll_request_limit_to_shift
      end
      add_poll_request
      send_request(uri, req)
    end

    def self.post(uri, parameters, headers)
      uri = URI(uri)
      req = Net::HTTP::Post.new(uri)
      req.set_form_data parameters
      headers.each do |key, val|
        req[key] = val
      end

      if create_requests_rate_limit_exeeded?
        wait_for_create_request_limit_to_shift
      end
      add_create_request
      send_request(uri, req)
    end

    def self.wait_for_poll_request_limit_to_shift
      i = 0
      while poll_requests_rate_limit_exeeded?
        wait_a_bit 5
        i += 1
        raise "Waiting for #{i} cycles - too long" if i > 50
      end
    end

    def self.wait_for_create_request_limit_to_shift
      i = 0
      while create_requests_rate_limit_exeeded?
        wait_a_bit 5
        i += 1
        raise "Waiting for #{i} cycles - too long" if i > 50
      end
    end

    def self.create_requests_rate_limit_exeeded?
      @@mutex.synchronize do
        @@create_requests.reject! { |x| time_passed?(x, REQUEST_LIMIT_DELAY) }
        @@create_requests.size >= CREATE_SESSION_LIMIT
      end
    end

    def self.add_create_request
      @@mutex.synchronize do
        @@create_requests.push Time.now
      end
    end

    def self.poll_requests_rate_limit_exeeded?
      @@mutex.synchronize do
        @@poll_requests.reject! { |x| time_passed?(x, REQUEST_LIMIT_DELAY) }
        @@poll_requests.size >= POLL_SESSION_LIMIT
      end
    end

    def self.add_poll_request
      @@mutex.synchronize do
        @@poll_requests.push Time.now
      end
    end

    def self.send_request(uri, req)
      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end
  end
end
