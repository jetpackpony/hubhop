module HubHop
  class Collector
    include HubHop::RedisConnect

    def initialize(input)
      @input = input
      @legs = []
    end

    def collect
      start_all_legs

      @legs.each(&:join).inject([]) do |res, thread|
        res.concat thread.value
      end
    end

    private

    def start_all_legs
      # Create direct legs
      @input[:from_place].each do |from|
        @input[:to_place].each do |to|
          @input[:dates].each do |date|
            create_leg from, to, date
          end
        end
      end

      # Create to hub legs
      @input[:from_place].each do |from|
        @input[:via_place].each do |to|
          @input[:dates].each do |date|
            create_leg from, to, date
          end
        end
      end

      # Create from hub legs
      dates = add_sequential_dates @input[:dates], @input[:max_transit_time]
      @input[:via_place].each do |from|
        @input[:to_place].each do |to|
          dates.each do |date|
            create_leg from, to, date
          end
        end
      end
    end

    def add_sequential_dates(dates, max_transit_time)
      new_dates = [].concat dates
      latest_date = Date.parse dates[dates.count - 1]
      ((max_transit_time.to_i / 24).floor + 1).times do
        latest_date += 1
        new_dates.push latest_date.to_s
      end
      new_dates
    end

    def create_leg(from, to, date)
      @legs << Thread.new do
        SkyScannerAPI.get_cached_quote from, to, date
      end
    end

    def wait_a_bit
      sleep 10
    end
  end
end
