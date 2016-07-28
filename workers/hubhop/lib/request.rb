require 'sidekiq'

module HubHop

  # If your client is single-threaded, we just need a single connection in our Redis connection pool
  Sidekiq.configure_client do |config|
    config.redis = { db: 1 }
  end

  # Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
  Sidekiq.configure_server do |config|
    config.redis = { db: 1}
  end

  class RequestWorker
    include Sidekiq::Worker

    def perform(id)
      sleep 1
      HubHop.redis.set "#{id}:completed", "true"
      HubHop.redis.set "#{id}:results", { results: true }.to_json
    end
  end
end
