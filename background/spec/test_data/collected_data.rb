module HubHopTestData
  def self.collected_data
    JSON.parse(
      IO.read("spec/test_data/collector_result.json"), :symbolize_keys => true
    ).map(&:deep_symbolize_keys).
      map do |x|
        x[:departure] = DateTime.parse(x[:departure])
        x[:arrival] = DateTime.parse(x[:arrival])
        x
      end
  end

  def self.cheapest_option
    {
      from: "",
      to: "",
      via: "",
      legs: [],
      total_price: 0.0
    }
  end
end

