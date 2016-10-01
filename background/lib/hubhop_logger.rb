require 'logger'

module HubHop
  def self.logger
    @logger || @logger = new_logger
  end

  def self.new_logger
    case ENV["LOGS_OUTPUT"]
    when /^file:(?<filename>.+)/
      logger = Logger.new $LAST_MATCH_INFO['filename'], 10, 1024000
    else
      logger = Logger.new STDOUT
    end

    case ENV["LOGGER_LEVEL"]
    when "info"
      logger.level = Logger::INFO
    else
      logger.level = Logger::DEBUG
    end
    logger
  end
end
