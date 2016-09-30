module HubHop
  module RedisConnect
    def redis
      @resis ||
        @redis = Redis.new(url: ENV["REDIS_URL"], db: ENV['REDIS_DB_NUMBER'])
    end
  end
end
