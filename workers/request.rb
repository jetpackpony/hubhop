require 'dotenv'
require 'net/http'
require 'json'
Dotenv.load

def build_request uri, from, to, date
  data = {
    apiKey: ENV['SKYS_API_KEY'],
    country: 'RU',
    currency: 'RUB',
    locale: 'ru-RU',
    originplace: "#{from}-iata",
    destinationplace: "#{to}-iata",
    outbounddate: date,
    adults: 1
  }

  req = Net::HTTP::Post.new uri
  req['Content-Type'] = 'application/x-www-form-urlencoded'
  req['Accept'] = 'application/json'
  req.set_form_data data

  req
end

def start_session from, to, date
  uri = URI('http://partners.api.skyscanner.net/apiservices/pricing/v1.0/')
  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request build_request uri, from, to, date
  end

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    return res['Location']
  else
    puts "Error: "
    puts res.body
    raise "Wrong request"
  end
end

puts start_session 'LED', 'LIS', '2016-09-25'

