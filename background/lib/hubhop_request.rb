module HubHop
  class Request
    include HubHop::RedisConnect
    attr_reader :request_id

    def initialize(request_id = nil)
      @request_id = request_id || ('a'..'z').to_a.shuffle[0,8].join
    end

    def start_search(form_data)
      redis.set "#{request_id}:completed", "false"
      redis.set "#{request_id}:request", { request_data: form_data }.to_json
      Search.perform_async request_id
      request_id
    end

    def check
      if redis.get("#{request_id}:completed") == "true"
        redis.get("#{request_id}:results")
      else
        false
      end
    end
  end
end