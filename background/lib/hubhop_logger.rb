require 'logger'

module HubHop
  def self.logger
    @logger || @logger = new_logger
  end

  def self.new_logger
    logger = build_logger ENV["LOGS_OUTPUT"]

    case ENV["LOGGER_LEVEL"]
    when "info"
      logger.level = Logger::INFO
    else
      logger.level = Logger::DEBUG
    end
    logger
  end

  def self.build_logger(log_output)
    case log_output
    when /^file:(?<filename>.+)/
      file = File.expand_path($LAST_MATCH_INFO['filename'], File.expand_path("../../", __FILE__))
      if File.exists? file
        return Logger.new file, 10, 1024000
      end
    end
    return Logger.new STDOUT
  end
end
