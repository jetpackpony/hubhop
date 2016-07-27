require 'sidekiq'

# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

# Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
Sidekiq.configure_server do |config|
  config.redis = { db: 1}
end

class PollSessionWorker
  include Sidekiq::Worker

  def perform session_id
    puts "Starting session #{session_id}"
    sleep(10)
    puts "Finished session #{session_id}"
  end
end
