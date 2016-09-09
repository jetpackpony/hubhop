module HubHop
  module RedisConnect
    def redis
      @resis || @redis = Redis.new(db: ENV['REDIS_DB_NUMBER'])
    end
  end
end
