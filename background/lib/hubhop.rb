require 'dotenv'
require 'sidekiq'
require 'byebug'
require 'pry'
Dotenv.load

require_relative "./reddis_connect"
require_relative "./hubhop_logger"
require_relative "./hubhop_leg_log"
require_relative "./hubhop_request"
require_relative "./validator"
require_relative "./hubhop_search"
require_relative "./hubhop_collector"
require_relative "./hubhop_flightgraph"
require_relative "./hubhop_skyscannerapi"

module HubHop
end
