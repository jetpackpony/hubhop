require_relative "./inputs"
require_relative "./api_calls"

module HubHopTestData
  def self.test_legs
    [
      { from: "LED", to: "LIS", date: "2016-12-02" },
      { from: "DME", to: "BCN", date: "2016-12-02" },
      { from: "DME", to: "OPO", date: "2016-12-01" },
      { from: "BCN", to: "OPO", date: "2016-12-04" }
    ]
  end

  def self.collected_data
    [
      { from: "LED", to: "BCN",
        date: Date.parse("2016-12-01"),
        price: "3000"},
      { from: "LED", to: "MUC",
        date: Date.parse("2016-12-02"),
        price: "6000"},
      { from: "DME", to: "BCN",
        date: Date.parse("2016-12-01"),
        price: "3500"},
      { from: "DME", to: "MUC",
        date: Date.parse("2016-12-01"),
        price: "8000"},
      { from: "MUC", to: "LIS",
        date: Date.parse("2016-12-01"),
        price: "2000"},
      { from: "MUC", to: "OPO",
        date: Date.parse("2016-12-01"),
        price: "2500"},
      { from: "MUC", to: "OPO",
        date: Date.parse("2016-12-02"),
        price: "6000"},
      { from: "MUC", to: "LIS",
        date: Date.parse("2016-12-02"),
        price: "6000"},
      { from: "BCN", to: "LIS",
        date: Date.parse("2016-12-01"),
        price: "3500"},
      { from: "BCN", to: "OPO",
        date: Date.parse("2016-12-01"),
        price: "8000"},
      { from: "BCN", to: "LIS",
        date: Date.parse("2016-12-02"),
        price: "7000"},
      { from: "LED", to: "LIS",
        date: Date.parse("2016-12-01"),
        price: "3000"},
      { from: "LED", to: "OPO",
        date: Date.parse("2016-12-01"),
        price: "4500"},
      { from: "DME", to: "LIS",
        date: Date.parse("2016-12-02"),
        price: "6000"},
      { from: "DME", to: "OPO",
        date: Date.parse("2016-12-01"),
        price: "3500"},
      { from: "LED", to: "LIS",
        date: Date.parse("2016-12-02"),
        price: "8000"},
    ]
  end

  def self.cheapest_option
  end

  def self.cached_quote_zero_results
    []
  end

  def self.get_leg_for(from, to, date)
    date = Date.parse(date)
    [
    collected_data.find do |x|
      x[:from] == from &&
        x[:to] == to &&
        x[:date] == date
    end
    ]
  end

  def self.cached_quote_result
    [{
      from: "LED",
      to: "OPO",
      date: Date.parse("2016-12-01"),
      price: 14790
    }]
  end

  def self.session_url
    "http://partners.api.skyscanner.net/apiservices/pricing/uk1/v1.0/329d5a074b274790b6eb78969d52d3f6_ecilpojl_7F251A752FD8E65A9D4D5E53BB9D4ED0"
  end

  def self.complete_session
    {}
  end

end

