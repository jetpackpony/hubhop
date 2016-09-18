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
        res.concat thread[:output]
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
        leg = Leg.new
        leg.log = LegLog.new from, to, date
        leg.from = from
        leg.to = to
        leg.date = date
        Thread.current[:output] = leg.query
      end
    end

    class Leg
      attr_accessor :from, :to, :date, :log

      def query
        session_url = SkyScannerAPI.create_session @from, @to, @date
        leg_id = "#{@from}, #{@to}, #{@date}: #{session_url}"
        res = false
        i = 0
        wait_a_bit 3
        start_time = Time.now
        while !res && (!time_passed?(start_time, 200) || i < 10) do
          res = SkyScannerAPI.poll_session session_url
          wait_a_bit i
          i += 1
        end

        if !res
          @log.log "Failed to retrieve data"
          []
        elsif res.count == 0
          @log.log "Got zero results for this leg!"
          []
        else
          res
        end
      end

      def time_passed?(start, diff)
        Time.now - start > diff
      end

      def wait_a_bit(i)
        sleep rand(10) + i*3
      end
    end
  end
end
