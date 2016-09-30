module HubHop
  module RedisConnect
    @@redis = false
    def redis
      @@redis ||
        @@redis = Redis.new(url: ENV["REDIS_URL"], db: ENV['REDIS_DB_NUMBER'])
    end
  end
end
