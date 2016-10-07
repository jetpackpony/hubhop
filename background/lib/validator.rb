module HubHop
  module Validator
    @iatas = nil

    def self.validate_input(data)
      err = {
        from_place: [],
        via_place: [],
        to_place: [],
        from_date: [],
        to_date: [],
        max_transit_time: []
      }
      err[:from_date].push validate_date data[:from_date]
      err[:to_date].push validate_date data[:to_date]
      if Date.parse(data[:from_date]) > Date.parse(data[:to_date])
        err[:to_date].push "TO date must be later than FROM date"
      end
      if data[:max_transit_time].to_i < 5
        err[:max_transit_time].push "The transit time has to be at least 5 hours"
      end
      if data[:max_transit_time].to_i > 186
        err[:max_transit_time].push "The transit time has to be at most 168 hours"
      end
      err[:from_place].concat check_airports(data[:from_place])
      err[:via_place].concat check_airports(data[:via_place])
      err[:to_place].concat check_airports(data[:to_place])

      err.
        # Remove nils from error arrays
        inject({}) { |h, (k, v)| h[k] = v.reject(&:nil?); h }.
        # Remove empty error arrays
        select { |k,v| v.size > 0 }
    end

    def self.validate_date(date)
      return "The date is in the past" if Date.parse(date) <= Date.today
      return "The date is way in the future" if Date.parse(date) >= Date.today + 365
    end

    def self.check_airports(list)
      list.map do |x|
        airport_exists?(x) ? nil : "Airport #{x} doesn't exist"
      end
    end

    def self.airport_exists?(airport)
      iatas.include? airport
    end

    def self.iatas
      @iatas || @iatas = JSON.parse(
        IO.read File.expand_path("../../iata_codes.json", __FILE__)
      )
    end
  end
end
