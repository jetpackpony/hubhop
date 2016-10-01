module HubHop
  class LegLog
    include HubHop::RedisConnect

    def initialize(request_id, from, to, date)
      @req_id, @from, @to, @date = request_id, from, to, date
    end

    def method_missing(name, *args, &block)
      if HubHop::logger.methods.include? name
        HubHop::logger.send name, "#{prefix} #{args.first}"
      else
        super
      end
    end

    private

    def prefix
      "[#{@req_id}:#{@from}->#{@to}_#{@date}]"
    end
  end
end
