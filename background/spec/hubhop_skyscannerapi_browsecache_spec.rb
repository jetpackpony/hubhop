require_relative 'test_data/flights'
require_relative '../lib/hubhop'

describe HubHop::SkyScannerAPI do
  let(:log) do
    l = instance_double Logger
    allow(l).to receive(:error)
    allow(l).to receive(:info)
    l
  end
  before do
    allow(HubHop::SkyScannerAPI).to receive(:wait_a_bit)
  end
  describe HubHop::SkyScannerAPI::BrowseCache do
    let(:browse_cache_api) do
      HubHop::SkyScannerAPI::BrowseCache.new log
    end

    describe ".get_cached_quote" do
      context "(with response successful)" do
        before do
          stub_browse_cache_200
        end

        it "supplies the correct end user IP to the request"
        it "returns an array of cached quotes" do
          expect(
            browse_cache_api.get_cached_quote "LED", "DME", "2016-12-01"
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
            browse_cache_api.get_cached_quote "LED", "DME", "2016-12-01"
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
            browse_cache_api.get_cached_quote "LED", "DME", "2016-12-01"
          rescue
          end
          expect(@stub1).to have_been_made.times(5)
        end

        it "logs a message if the data couldn't be retrieved" do
          begin
            browse_cache_api.get_cached_quote "LED", "DME", "2016-12-01"
          rescue
          end
          expect(log).to have_received(:error).at_least(:once)
        end
      end
    end
  end
end
