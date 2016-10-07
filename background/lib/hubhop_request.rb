module HubHop
  class Request
    attr_reader :request_id

    def initialize(request_id = nil)
      @request_id = request_id || ('a'..'z').to_a.shuffle[0,8].join
    end

    def start_search(form_data)
      if HubHop::Validator.validate_input(form_data).size > 0
        raise "Input data didn't pass validation"
      end
      HubHop::redis.set "#{request_id}:completed", "false"
      HubHop::redis.set "#{request_id}:request", { request_data: form_data }.to_json
      Search.perform_async request_id
      request_id
    end

    def check
      if complete?
        HubHop::redis.get("#{request_id}:results")
      else
        false
      end
    end

    private

    def complete?
      complete = HubHop::redis.get("#{request_id}:completed")
      raise "This request id doesn't exist" if complete.nil?
      complete == "true"
    end
  end
end
