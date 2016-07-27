require './poll_session_worker'

0.upto(10) do |id|
  PollSessionWorker.perform_async id
  sleep 1
end
