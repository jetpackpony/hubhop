require 'dotenv'
require 'net/http'
require 'json'
Dotenv.load

pull_url = "http://partners.api.skyscanner.net/apiservices/pricing/uk1/v1.0/3299aeb2aab64660a1611472a7b8d2be_ecilpojl_ABF589BE2F64AB772CAE67D9D6A2BF11"

pull_url << "?apiKey=" + ENV['SKYS_API_KEY']
pull_url << "&stops=0"
#pull_url << "&outbounddepartstarttime=00:01"
#pull_url << "&outbounddepartendtime=00:01"
puts "sleeping..."
sleep 10
puts "sending the request: #{pull_url}"

pull_url = URI(pull_url)

req = Net::HTTP::Get.new pull_url
req['Accept'] = 'application/json'

res = Net::HTTP.start(pull_url.hostname, pull_url.port) do |http|
  http.request req
end

case res
when Net::HTTPSuccess, Net::HTTPRedirection
  open('poll_response.json', 'w') do |f|
    f.puts JSON.parse(res.body).inspect
  end
else
  puts "Error getting the pull response!"
  puts res.body
  raise "Wrong pull response"
end
