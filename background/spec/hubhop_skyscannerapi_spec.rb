require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::SkyScannerAPI do
  before do
    allow(HubHop::Log).to receive(:log)
    allow(HubHop::SkyScannerAPI).to receive(:wait_a_bit)
  end

  describe ".create_session" do
    let(:create_session) do
      HubHop::SkyScannerAPI.create_session "LED", "DME", "2016-12-01"
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
        expect(@stub1).to have_been_made.times(5)
      end
      it "logs an error message" do
        begin
          create_session
        rescue
        end
        expect(HubHop::Log).to have_received(:log).at_least(:once)
      end
      it "raises an error" do
        expect { create_session }.
          to raise_error "Couldn't create a search session"
      end
    end
  end

  describe ".poll_session" do
    let(:poll_session) do
      HubHop::SkyScannerAPI.poll_session HubHopTestData.session_url
    end

    context "(with response successful)" do
      it "returns false if the session is not yet complete" do
        stub_poll_session_incomplete
        expect(poll_session).to be false
      end
      it "returns an array of flights if the session is complete" do
        skip
        stub_poll_session_complete
        expect(poll_session).to eq HubHopTestData.complete_session
      end
    end
    context "(with response unsuccessful)" do
      it "raises an error"
    end
  end

  describe ".get_cached_quote" do
    context "(with response successful)" do
      before do
        stub_browse_cache_200
      end

      it "supplies the correct end user IP to the request"
      it "returns an array of cached quotes" do
        expect(
          HubHop::SkyScannerAPI.get_cached_quote "LED", "DME", "2016-12-01"
        ).
        to eq(HubHopTestData.cached_quote_result)
      end
    end

    context "(with zero quotes returned)" do
      before do
        stub_browse_cache_zero_results_200
      end

      it "does something when zero quotes are returned" do
        expect(
          HubHop::SkyScannerAPI.get_cached_quote "LED", "DME", "2016-12-01"
        ).
        to eq(HubHopTestData.cached_quote_zero_results)
      end
    end

    context "(with response not successful)" do
      before(:all) do
        @stub1 = stub_browse_cache_429
      end

      it "runs quote request multiple times if the error is returned" do
        begin
          HubHop::SkyScannerAPI.get_cached_quote "LED", "DME", "2016-12-01"
        rescue
        end
        expect(@stub1).to have_been_made.times(5)
      end

      it "logs a message if the data couldn't be retrieved" do
        begin
          HubHop::SkyScannerAPI.get_cached_quote "LED", "DME", "2016-12-01"
        rescue
        end
        expect(HubHop::Log).to have_received(:log).at_least(:once)
      end
    end
  end
end
