require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::Collector do
  let(:collector_input) { HubHopTestData.collector_input }
  let(:collected_data) { HubHopTestData.collected_data }
  let(:test_legs) { HubHopTestData.test_legs }
  let(:collector) { HubHop::Collector.new collector_input }

  describe "#collect" do
    before do
      allow(collector).to receive(:wait_a_bit)
      allow(HubHop::SkyScannerAPI).
        to receive(:get_cached_quote) do |from, to, date|
          HubHopTestData.get_leg_for from, to, date
        end
    end

    it "calls SkyScanner API for each leg to get a chached quote" do
      collector.collect

      expect(HubHop::SkyScannerAPI).
        to have_received(:get_cached_quote).
        exactly(32).times

      test_legs.each do |leg|
        expect(HubHop::SkyScannerAPI).
          to have_received(:get_cached_quote).
          with(leg[:from], leg[:to], leg[:date])
      end
    end

    it "returns the composed result of all the session polls" do
      collected_data.each do |expected_flight|
        expect(collector.collect).to include expected_flight
      end
    end
  end
end
