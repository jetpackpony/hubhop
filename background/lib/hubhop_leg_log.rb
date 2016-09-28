module HubHop
  class LegLog
    include HubHop::RedisConnect

    def initialize(request_id, from, to, date)
      @req_id, @from, @to, @date = request_id, from, to, date
    end

    def log(text, level)
      redis.set key, append(preprocess(text, level))
    end

    private

    def key
      "#{@req_id}:log:#{@from}_#{@to}_#{@date}"
    end

    def append(text)
      (redis.get(key) || "") + text
    end

    def preprocess(text, level)
      txt = DateTime.now.strftime("[%Y-%m-%d %H:%M:%S] ") + text + "\n"
      if level == :error
        caller(0).each do |str|
          txt += "    " + str + "\n"
        end
      end
      txt
    end
  end
end
