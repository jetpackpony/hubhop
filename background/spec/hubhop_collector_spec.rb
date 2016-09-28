require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::Collector do
  let(:collector_input) { HubHopTestData.collector_input }
  let(:test_legs) { HubHopTestData.test_legs }
  let(:collector) { HubHop::Collector.new collector_input }

  describe "#collect" do
    let(:test_hash) { { test: 'test' } }
    let(:leg) { HubHop::Collector::Leg.new }

    before do
      l = instance_double(HubHop::Collector::Leg)
      allow(l).to receive(:from=)
      allow(l).to receive(:to=)
      allow(l).to receive(:date=)
      allow(l).to receive(:log=)
      allow(l).to receive(:query) { [test_hash] }
      allow(HubHop::Collector::Leg).to receive(:new) { l }
    end

    it "creates a Leg object for each leg" do
      collector.collect
      expect(HubHop::Collector::Leg).
        to have_received(:new).
        exactly(32).times
    end

    it "creates a Leg object with correct arguments" do
      collector.collect
      test_legs.each do |test_leg|
        expect(leg).
          to have_received(:from=).
          with(test_leg[:from]).
          at_least(:once)
        expect(leg).
          to have_received(:to=).
          with(test_leg[:to]).
          at_least(:once)
        expect(leg).
          to have_received(:date=).
          with(test_leg[:date]).
          at_least(:once)
      end
    end

    it "injects a log object into the Leg object" do
      collector.collect
      expect(leg).
        to have_received(:log=).
        at_least(:once)
    end

    it "returns an array of the leg query results" do
      coll = collector.collect
      expect(coll).to be_a Array
      expect(coll.count).to eq 32
    end

    it "includes the expected results in the result array" do
      expect(collector.collect).to include test_hash
    end

    it "calls no more than 100 requests per minute"
  end
end

describe HubHop::Collector::Leg do
  describe "#query" do
    let(:data) { HubHopTestData.test_legs.first }
    let(:log) do
      l = instance_double HubHop::LegLog
      allow(l).to receive(:log)
      l
    end
    let(:leg) do
      leg = HubHop::Collector::Leg.new
      leg.from = data[:from]
      leg.to = data[:to]
      leg.date = data[:date]
      leg.log = log
      leg
    end
    let(:leg_result) do
      HubHopTestData.live_price_result(
        data[:from], data[:to], data[:date]
      )
    end
    let(:live_pricing_api) do
      api = instance_double HubHop::SkyScannerAPI::LivePricing
      allow(api).to receive(:create_session)
      allow(api).to receive(:poll_session) { leg_result }
      api
    end
    before do
      allow(leg).to receive(:wait_a_bit)
      allow(leg).to receive(:time_passed?) { true }
      allow(HubHop::SkyScannerAPI::LivePricing).
        to receive(:new) { live_pricing_api }
    end

    it "creates a SkyScannerAPI live pricing object" do
      leg.query
      expect(HubHop::SkyScannerAPI::LivePricing).
        to have_received(:new).
        once
    end

    it "creates a SkyScanner search session" do
      leg.query
      expect(live_pricing_api).
        to have_received(:create_session).
        once
    end
    it "polls a SkyScanner session to get results" do
      leg.query
      expect(live_pricing_api).
        to have_received(:poll_session).
        once
    end

    context "(if the session is successfull)" do
      it "returns an array of flights from the session" do
        expect(leg.query).to eq leg_result
      end
      it "logs a message with the number of results retrieved" do
        leg.query
        expect(log).
          to have_received(:log).
          with("Retrieved 2 results", :info)
      end
    end

    context "(if the session can't retrieve data)" do
      before do
        allow(live_pricing_api).
          to receive(:poll_session) { false }
      end

      it "returns an empty array", focus: true do
        expect(leg.query).to eq []
      end
      it "logs a message with an error", focus: true do
        leg.query
        expect(log).
          to have_received(:log).
          with("Failed to retrieve data", :error)
      end
    end

    context "(if the session finds no flights" do
      before do
        allow(live_pricing_api).
          to receive(:poll_session) { [] }
      end

      it "returns an empty array", focus: true do
        expect(leg.query).to eq []
      end
      it "logs a message with an error", focus: true do
        leg.query
        expect(log).
          to have_received(:log).
          with("Got zero results for this leg!", :info)
      end
    end
  end
end
