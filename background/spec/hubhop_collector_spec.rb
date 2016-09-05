require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::Collector do
  let(:collector_input) { HubHopTestData.collector_input }
  let(:polled_data) { HubHopTestData.polled_data }
  let(:collected_data) do
    HubHopTestData.polled_data.
      inject([]) do |res, flights|
        res.concat flights[1]
      end
  end
  let(:test_legs) { HubHopTestData.test_legs }
  let(:collector) { HubHop::Collector.new collector_input }


  describe "#collect" do
    it "creates a search session for every leg of the trip" do
      collector.collect
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        exactly(32).times
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("LED", "BAR", "2016-09-01")
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("LED", "LIS", "2016-09-02")
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("DME", "BAR", "2016-09-02")
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("DME", "POR", "2016-09-01")
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("BAR", "POR", "2016-09-04")
    end
    it "creates a worker to poll each of the sessions"
    it "waits for all the workers to finish"
    it "returns the composed result of the api requests" do
      skip
      expect(collector.collect[:flights].count).to eq collected_data[:flights].count
    end
  end
end
