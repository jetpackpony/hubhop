require_relative '../test_data/flights'
require_relative '../../lib/hubhop'

module HubHop
  module APIStubs
    include HubHop::SkyScannerAPI::Constants

    def stub_browse_cache_200
      stub_request(:get, /.*#{BROWSE_CACHE_ADDRESS}.*/).
        to_return(:status => 200,
                  :body => HubHopTestData.browse_quote,
                  :headers => {})
    end

    def stub_browse_cache_429
      stub_request(:get, /.*#{BROWSE_CACHE_ADDRESS}.*/).
        to_return(:status => 429,
                  :body => "",
                  :headers => {})
    end

    def stub_browse_cache_zero_results_200
      stub_request(:get, /.*#{BROWSE_CACHE_ADDRESS}.*/).
        to_return(:status => 200,
                  :body => HubHopTestData.browse_quote_zero_results,
                  :headers => {})
    end

    def stub_create_session_429
      stub_request(:post, /.*#{CREATE_PRICING_SESSION_ADDRESS}.*/).
         to_return(:status => 429,
                   :body => "",
                   :headers => {})
    end

    def stub_create_session_201
      stub_request(:post, /.*#{CREATE_PRICING_SESSION_ADDRESS}.*/).
         to_return(:status => 201,
                   :body => "",
                   :headers => {'Location' => HubHopTestData.session_url })
    end

    def stub_poll_session_incomplete
      stub_request(:get, /.*#{HubHopTestData.session_url}.*/).
         to_return(:status => 200,
                   :body => HubHopTestData.live_prices_incomplete,
                   :headers => {})
    end

    def stub_poll_session_complete
      stub_request(:get, /.*#{HubHopTestData.session_url}.*/).
         to_return(:status => 200,
                   :body => HubHopTestData.live_prices_complete,
                   :headers => {})
    end

    def stub_poll_session_429
      stub_request(:get, /.*#{HubHopTestData.session_url}.*/).
         to_return(:status => 429,
                   :body => "",
                   :headers => {})
    end
  end
end

RSpec.configure do |config|
  config.include HubHop::APIStubs
end

