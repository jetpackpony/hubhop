module HubHopTestData
  def self.browse_quote
    IO.read "spec/test_data/browse_quote.json"
  end

  def self.browse_quote_zero_results
    IO.read "spec/test_data/browse_quote_zero_results.json"
  end

  def self.live_prices_incomplete
    IO.read "spec/test_data/live_prices_incomplete.json"
  end

  def self.live_prices_complete
    IO.read "spec/test_data/live_prices_complete.json"
  end
end
