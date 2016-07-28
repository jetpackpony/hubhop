require_relative '../lib/hubhop'
require 'byebug'

describe HubHop do
  after(:all) do
    Redis.new(db: ENV['REDIS_DB_NUMBER']).flushdb
  end

  describe ".request_id" do
    it "returns a string" do
      expect(HubHop.request_id).to be_a String
    end
  end

  describe ".start" do
    let(:form_data) { { "from_place": [] } }
    let(:redis_record) { Redis.new.get("#{HubHop.request_id}:request") }

    before do
      allow(HubHop::RequestWorker).to receive(:perform_async)
      allow(HubHop).to receive(:request_id) { "==request_id==" }
    end

    it "creates request record in the database" do
      HubHop.start form_data
      expect(redis_record).to eq({ request_data: form_data }.to_json)
    end

    it "starts the request processing background job" do
      HubHop.start form_data
      expect(HubHop::RequestWorker).
        to have_received(:perform_async).
        with(HubHop.request_id).
        once
    end

    it "it returns the request id" do
      expect(HubHop.start form_data).to eq HubHop.request_id
    end
  end

  describe ".check" do
    before do
      allow(HubHop).to receive(:request_id) { "==request_id==" }
    end

    context "request processing not completed" do
      it "returns false" do
        Redis.new.set "#{HubHop.request_id}:completed", "false"
        expect(HubHop.check HubHop.request_id).to be false
      end
    end

    context "request processing has completed" do
      let(:results) { { results: true }.to_json }
      it "returns hash with results" do
        Redis.new.set "#{HubHop.request_id}:completed", "true"
        Redis.new.set "#{HubHop.request_id}:results", results
        expect(HubHop.check HubHop.request_id).to eq results
      end
    end
  end
end
