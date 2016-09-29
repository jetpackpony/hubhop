require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::SkyScannerAPI do
  let(:log) do
    l = instance_double HubHop::LegLog
    allow(l).to receive(:log)
    l
  end
  before do
    allow(HubHop::SkyScannerAPI).to receive(:wait_a_bit)
    allow(HubHop::SkyScannerAPI).to receive(:wait_for_poll_request_limit_to_shift)
    allow(HubHop::SkyScannerAPI).to receive(:wait_for_create_request_limit_to_shift)
    allow(HubHop::SkyScannerAPI).to receive(:time_passed?) { false }
  end

  context "(stabbed requests to void)" do
    before do
      allow(HubHop::SkyScannerAPI).to receive(:send_request)
    end

    describe ".perform_request" do
      it "sends a request no more than POLL_SESSION_LIMIT times per minute" do
        (HubHop::SkyScannerAPI::POLL_SESSION_LIMIT + 5).times do
          HubHop::SkyScannerAPI::perform_request "http://google.com/"
        end
        expect(HubHop::SkyScannerAPI).
          to have_received(:wait_for_poll_request_limit_to_shift).
          at_least(:once)
      end
    end

    describe ".post" do
      it "sends a request no more than CREATE_SESSION_LIMIT times per minute" do
        (HubHop::SkyScannerAPI::CREATE_SESSION_LIMIT + 5).times do
          HubHop::SkyScannerAPI::post "http://google.com/", {}, {}
        end
        expect(HubHop::SkyScannerAPI).
          to have_received(:wait_for_create_request_limit_to_shift).
          at_least(:once)
      end
    end
  end

  describe HubHop::SkyScannerAPI::LivePricing do
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
            to have_received(:log).
            with("Re-running the request. 429. Body: ", :info).
            at_least(:once)
        end
        it "logs an error message" do
          begin
            create_session
          rescue
          end
          expect(log).
            to have_received(:log).
            with(/Can't retrieve data for from:LED, to:DME, date:2016-12-01/, :error).
            at_least(:once)
        end
        it "raises an error" do
          expect { create_session }.
            to raise_error "Couldn't create a search session"
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
            to have_received(:log).
            with("Re-running the request. 429. Body: ", :info).
            at_least(:once)
        end
        it "raises an error" do
          expect { poll_session }.
            to raise_error "Couldn't poll a search session result"
        end
      end
    end
  end
end
