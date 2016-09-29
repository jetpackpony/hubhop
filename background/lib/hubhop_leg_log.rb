module HubHop
  class LegLog
    include HubHop::RedisConnect

    def self.merge_logs(req_id, logs)
      logs.first.redis.set(
        "#{req_id}:log",
        logs.inject("") do |msg, log|
          msg + log.text + "\n"
        end
      )
      logs.each { |log| logs.first.redis.del log.key }
    end

    def initialize(request_id, from, to, date)
      @req_id, @from, @to, @date = request_id, from, to, date
    end

    def log(text, level)
      redis.set key, append(preprocess(text, level))
    end

    def text
      redis.get(key) || ""
    end

    def key
      "#{@req_id}:log:#{@from}_#{@to}_#{@date}"
    end

    private

    def append(text)
      (redis.get(key) || "") + text
    end

    def preprocess(text, level)
      txt = DateTime.now.strftime("[%Y-%m-%d %H:%M:%S]")
      txt += "[#{level.to_s.capitalize}]"
      txt += " " + text + "\n"
      if level == :error
        caller(0).each do |str|
          txt += "    " + str + "\n"
        end
      end
      txt
    end
  end
end
