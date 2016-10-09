web: bundle exec ruby ./frontend/app.rb -p $PORT
worker: bundle exec sidekiq -r ./background/sidekiq_server.rb -c 2
