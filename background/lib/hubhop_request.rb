module HubHop
  class Request
    attr_reader :request_id

    def initialize(request_id = nil)
      @request_id = request_id || ('a'..'z').to_a.shuffle[0,8].join
    end

    def start_search(form_data)
      validate_input form_data
      HubHop::redis.set "#{request_id}:completed", "false"
      HubHop::redis.set "#{request_id}:request", { request_data: form_data }.to_json
      Search.perform_async request_id
      request_id
    end

    def check
      if HubHop::redis.get("#{request_id}:completed") == "true"
        HubHop::redis.get("#{request_id}:results")
      else
        false
      end
    end

    private

    def validate_input(data)
      validate_date data[:from_date]
      validate_date data[:to_date]
      if Date.parse(data[:from_date]) > Date.parse(data[:to_date])
        raise "TO date must be at least the FROM date"
      end
      if data[:max_transit_time].to_i < 5
        raise "The transit time has to be at least 5 hours"
      end
      if data[:max_transit_time].to_i > 186
        raise "The transit time has to be at most 168 hours"
      end
    end

    def validate_date(date)
      if Date.parse(date) <= Date.today
        raise "At least one of the dates is in the past"
      end
      if Date.parse(date) >= Date.today + 365
        raise "At least one of the dates is in the future"
      end
    end
  end
end
