require 'redis'

module HubHop

  def self.redis
    @redis || @redis = new_connection
  end

  def self.new_connection
    Redis.new(url: ENV["REDIS_URL"], db: ENV['REDIS_DB_NUMBER'])
  end
end
