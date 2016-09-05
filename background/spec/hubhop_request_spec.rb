require_relative '../lib/hubhop'

describe HubHop::Request do
  include HubHop::RedisConnect
  let(:request) { HubHop::Request.new }

  after(:all) do
    redis.flushdb
  end

  describe "#start" do
    let(:form_data) { { "from_place": [] } }
    let(:redis_record) { redis.get("#{request.request_id}:request") }

    before do
      allow(HubHop::Search).to receive(:perform_async)
    end

    it "creates request record in the database" do
      request.start_search form_data
      expect(redis_record).to eq({ request_data: form_data }.to_json)
    end

    it "starts the request processing background job" do
      request.start_search form_data
      expect(HubHop::Search).
        to have_received(:perform_async).
        with(request.request_id).
        once
    end

    it "it returns the request id" do
      expect(request.start_search form_data).to eq request.request_id
    end
  end

  describe "#check" do
    context ">> if request processing not completed," do
      it "returns false" do
        redis.set "#{request.request_id}:completed", "false"
        expect(request.check).to be false
      end
    end

    context ">> request processing has completed," do
      let(:results) { { results: true }.to_json }
      it "returns hash with results" do
        redis.set "#{request.request_id}:completed", "true"
        redis.set "#{request.request_id}:results", results
        expect(request.check).to eq results
      end
    end
  end
end
