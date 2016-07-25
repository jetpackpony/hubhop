require 'dotenv'
require 'net/http'

Dotenv.load

link = 'http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/'
link << 'RU/'
link << 'RUB/'
link << 'ru-RU/'
link << 'LED/'
link << 'DME/'
link << '2016-09-01/'
link << '?apiKey=' + ENV['SKYS_API_KEY']


res = Net::HTTP.get(URI(link))
puts res
