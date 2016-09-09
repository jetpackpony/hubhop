require 'sidekiq'
require_relative './lib/hubhop'

Sidekiq.configure_server do |config|
  config.redis = { db: 1}
end
