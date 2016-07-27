require './poll_session_worker'
require 'sidekiq/api'

sleep 3
workers = Sidekiq::Workers.new
while workers.size > 0
  puts "Still running #{workers.size} processes..."
  sleep 1
end
puts "All done"

