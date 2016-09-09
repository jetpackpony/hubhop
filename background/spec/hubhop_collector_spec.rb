require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::Collector do
  let(:collector_input) { HubHopTestData.collector_input }
  let(:test_legs) { HubHopTestData.test_legs }
  let(:collector) { HubHop::Collector.new collector_input }

  describe "#collect" do
    before do
      allow(collector).to receive(:wait_a_bit)
      allow(HubHop::SkyScannerAPI).
        to receive(:create_session) do |from, to, date|
          "#{from}_#{to}_#{date}"
        end
      allow(HubHop::SkyScannerAPI).
        to receive(:poll_session) do |session_url|
          HubHopTestData.live_price_result(
            *session_url.split("_")
          )
        end
    end

    it "creates a SkyScannerAPI session for each leg" do
      collector.collect

      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        exactly(32).times

      test_legs.each do |leg|
        expect(HubHop::SkyScannerAPI).
          to have_received(:create_session).
          with(leg[:from], leg[:to], leg[:date])
      end
    end

    it "polls the SkyScannerAPI session for leg results" do
      collector.collect

      expect(HubHop::SkyScannerAPI).
        to have_received(:poll_session).
        exactly(32).times
    end

    it "returns the composed result of all the session polls" do
      coll = collector.collect
      expect(coll).to be_a Array
      expect(coll.count).to eq 64
      test_legs.each do |leg|
        leg_prices = HubHopTestData.live_price_result(
          leg[:from], leg[:to], leg[:date])
        expect(coll).to include leg_prices[0]
        expect(coll).to include leg_prices[1]
      end
    end

    it "does something if the leg didn't return any results"
    it "calls no more than 100 requests per minute"
  end
end
