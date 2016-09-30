module HubHopTestData
  def self.collected_data
    self.collected_data_unfiltered.select { |x| x.is_a? Hash }
  end

  def self.cheapest_option
    {
      name: "DME->LIS",
      from: "DME",
      to: "LIS",
      via: "",
      legs: self.dme_lis_legs,
      total_price: self.dme_lis_legs.inject(0) { |sum, x| sum += x[:price] }
    }
  end

  def self.cheapest_five
    ["something"]
  end

  def self.cheapest_direct
    cheapest_option
  end

  def self.led_opo_legs
    [
      HubHopTestData.collected_data.find do |x|
        x[:from][:code] == "LED" && x[:to][:code] == "MUC" &&
          x[:departure] == DateTime.parse("2016-12-02T10:30:00+00:00")
      end,
      HubHopTestData.collected_data.find do |x|
        x[:from][:code] == "MUC" && x[:to][:code] == "OPO" &&
          x[:departure] == DateTime.parse("2016-12-03T16:25:00+00:00")
      end
    ]
  end

  def self.dme_lis_legs
    [
      HubHopTestData.collected_data.find do |x|
        x[:from][:code] == "DME" && x[:to][:code] == "LIS" &&
          x[:departure] == DateTime.parse("2016-12-02T05:00:00+00:00") &&
          x[:carrier][:name] == "TAP Portugal"
      end
    ]
  end

  def self.collected_data_unfiltered
    JSON.parse(
      IO.read("spec/test_data/collector_result.json"), :symbolize_keys => true
    ).map { |x| (x.is_a? Hash) ? x.deep_symbolize_keys : x }.
      map do |x|
        if x.is_a? Hash
          x[:departure] = DateTime.parse(x[:departure])
          x[:arrival] = DateTime.parse(x[:arrival])
        end
        x
      end
  end
end

