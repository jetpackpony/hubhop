require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::SkyScannerAPI::LivePricing do
  let(:log) do
    l = instance_double Logger
    allow(l).to receive(:error)
    allow(l).to receive(:info)
    allow(l).to receive(:debug)
    l
  end
  before do
    throttle = instance_double HubHop::SkyScannerAPI::Throttle
    allow(throttle).to receive(:delay) { |&b| b.call }
    HubHop::SkyScannerAPI.class_variable_set(:@@throttle_post, throttle)
    HubHop::SkyScannerAPI.class_variable_set(:@@throttle_get, throttle)
    allow(HubHop::SkyScannerAPI).to receive(:wait_a_bit)
  end

  let(:live_pricing_api) do
    HubHop::SkyScannerAPI::LivePricing.new log
  end

  describe ".create_session" do
    let(:create_session) do
      live_pricing_api.create_session "LED", "DME", "2016-12-01"
    end

    context "(with response successful)" do
      before do
        stub_create_session_201
      end
      it "returns the poll session url of the created session" do
        expect(create_session).to eq HubHopTestData.session_url
      end
    end

    context "(with response unsuccessful)" do
      before do
        @stub1 = stub_create_session_429
      end
      it "re-runs the request multiple times" do
        begin
          create_session
        rescue
        end
        expect(@stub1).to have_been_made.times(10)
      end
      it "logs a message about re-running the request" do
        begin
          create_session
        rescue
        end
        expect(log).
          to have_received(:info).
          with("Re-running the request. 429. Body: ").
          at_least(:once)
      end
      it "logs an error message" do
        begin
          create_session
        rescue
        end

        expect(log).
          to have_received(:error).
          with(/Can't retrieve data for from:LED, to:DME, date:2016-12-01/).
          at_least(:once)
      end
      it "raises an error" do
        expect { create_session }.
          to raise_error "Couldn't create search session"
      end
    end
  end

  describe ".poll_session" do
    let(:poll_session) do
      live_pricing_api.poll_session HubHopTestData.session_url
    end

    context "(with response successful)" do
      it "returns false if the session is not yet complete" do
        stub_poll_session_incomplete
        expect(poll_session).to be false
      end
      it "returns an array of flights if the session is complete" do
        stub_poll_session_complete
        expect(poll_session[0]).to eq HubHopTestData.complete_session[0]
        expect(poll_session[1]).to eq HubHopTestData.complete_session[1]
      end
    end
    context "(with response unsuccessful)" do
      before do
        stub_poll_session_429
      end
      it "logs a message about re-running the request" do
        begin
          poll_session
        rescue
        end
        expect(log).
          to have_received(:info).
          with("Re-running the request. 429. Body: ").
          at_least(:once)
      end
      it "raises an error" do
        expect { poll_session }.
          to raise_error "Couldn't poll a search session result"
      end
    end
  end
end
