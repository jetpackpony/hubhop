require_relative "./inputs"
require_relative "./api_calls"
require_relative "./collected_data"

module HubHopTestData
  def self.test_legs
    [
      { from: "LED", to: "LIS", date: "2016-12-02" },
      { from: "DME", to: "BCN", date: "2016-12-02" },
      { from: "DME", to: "OPO", date: "2016-12-01" },
      { from: "BCN", to: "OPO", date: "2016-12-04" }
    ]
  end

  def self.live_price(from, to, date)
    HubHopTestData.live_price_result(from, to, date).
      sort { |a, b| a[:price] <=> b[:price] }.
      first
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
    live_price_result("LED", "MUC", "2016-12-02")
  end

  def self.live_price_result(from, to, date)
    [
      {
        from: {
          code: from
        },
        to: {
          code: to
        },
        departure: DateTime.parse("#{date}T10:30:00+00:00"),
        arrival: DateTime.parse("#{date}T11:20:00+00:00"),
        price: 7395.0,
        deeplink: "http://skyscanner.net/deeplink",
        carrier: {
          name: "Aeroflot"
        },
        agent: {
          name: "Go2See"
        }
      },
      {
        from: {
          code: from
        },
        to: {
          code: to
        },
        departure: DateTime.parse("#{date}T17:25:00+00:00"),
        arrival: DateTime.parse("#{date}T18:20:00+00:00"),
        price: 16074.0,
        deeplink: "http://skyscanner.net/deeplink",
        carrier: {
          name: "Lufthansa"
        },
        agent: {
          name: "Lufthansa"
        }
      }
    ]
  end
end
