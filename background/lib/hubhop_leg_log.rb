module HubHop
  class LegLog
    include HubHop::RedisConnect

    def initialize(request_id, from, to, date)
      @req_id, @from, @to, @date = request_id, from, to, date
    end

    def log(text)
      redis.set key, append(preprocess(text))
    end

    private

    def key
      "#{@req_id}:log:#{@from}_#{@to}_#{@date}"
    end

    def append(text)
      (redis.get(key) || "") + text
    end

    def preprocess(text)
      DateTime.now.strftime("[%Y-%m-%d %H:%M:%S] ") + text + "\n"
    end
  end
end
