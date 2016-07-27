module HubHop
  def self.start(form_data)
    redis.set "#{request_id}:request", { request_data: form_data }.to_json
    RequestWorker.perform_async request_id
    request_id
  end

  def self.check(id)
    if redis.get("#{id}:completed") == "true"
      redis.get("#{id}:results")
    else
      false
    end
  end

  def self.request_id
    ('a'..'z').to_a.shuffle[0,8].join
  end

  def self.redis
    @redis || @redis = Redis.new(db: ENV['REDIS_DB_NUMBER'])
  end
end
