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
    before do
      allow(collector).to receive(:wait_a_bit)
      allow(HubHop::SkyScannerAPI).
        to receive(:create_session) do |from, to, date|
          [from, to, date.gsub("-", "_")].
            map(&:downcase).
            join("_")
        end
      allow(HubHop::SkyScannerAPI).
        to receive(:poll_session) do |session_id|
          value = polled_data[session_id.to_sym]
          value.is_a?(Array) ? value : []
        end
    end

    it "calls SkyScanner API for each leg to create a session" do
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

    it "calls SkyScanner API to poll each session" do
      collector.collect

      expect(HubHop::SkyScannerAPI).
        to have_received(:poll_session).
        exactly(32).times

      test_legs.each do |leg|
        expect(HubHop::SkyScannerAPI).
          to have_received(:poll_session).
          with(
            HubHop::SkyScannerAPI.
              create_session leg[:from], leg[:to], leg[:date]
          )
      end
    end

    it "returns the composed result of all the session polls" do
      collected_data.each do |expected_flight|
        expect(collector.collect).to include expected_flight
      end
    end
  end
end
