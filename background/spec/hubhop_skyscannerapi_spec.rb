require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::SkyScannerAPI do
  before do
    stub_request(:get, /.*#{HubHop::SkyScannerAPI::BROWSE_CACHE_ADDRESS}.*/).
      to_return(:status => 200,
                :body => HubHopTestData.browse_quote,
                :headers => {})

  end

  describe ".create_session" do
    it "sends the request to SkyScanner API to start a session"
    it "returns the session_id received from SkyScanner API"
  end

  describe ".poll_session" do
    it "polls the ticket search session from SkyScanner API"
    it "returns false if the session is not yet complete"
    it "returns an array of flights if the session is complete"
  end

  describe ".get_cached_quote" do
    it "supplies the correct end user IP to the request"
    it "returns the cheapest quote for the request" do
      expect(
        HubHop::SkyScannerAPI.get_cached_quote "LED", "DME", "2016-09-01"
      ).
      to eq(HubHopTestData.cached_quote_result)
    end
  end
end
