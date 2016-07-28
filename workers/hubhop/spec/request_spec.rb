require_relative '../lib/hubhop'
require 'byebug'

describe HubHop do
  describe HubHop::Request do
    let(:request_id) { "==request_id==" }
    let(:request_data) { build :form_data }
    let(:request) { HubHop::Request.new request_id}

    after(:each) do
      Redis.new(db: ENV['REDIS_DB_NUMBER']).flushdb
    end

    describe "#run" do
      before(:each) do
        allow(request).to receive(:setup)
        allow(request).to receive(:process)
        allow(request).to receive(:complete)
        request.run
      end

      it "calls the setup method" do
        expect(request).to have_received(:setup)
      end
      it "calls the process method" do
        expect(request).to have_received(:process)
      end
      it "calls the complete method" do
        expect(request).to have_received(:complete)
      end
    end

    describe "#setup" do
      before(:each) do
        HubHop.redis.set "#{request_id}:request", request_data.to_json
      end

      it "creates 'completed=false' record in the db" do
        request.setup
        expect(HubHop.redis.get("#{request_id}:completed")).to eq "false"
      end
      it "loads the request data from the database" do
        request.setup
        expect(request.input).to eq request_data
      end
    end

    describe "#complete" do
      before(:each) do
        HubHop.redis.set "#{request_id}:request", request_data.to_json
        HubHop.redis.set "#{request_id}:completed", "false"
      end

      it "creates 'completed=true' record in the db when finished" do
        request.complete
        expect(HubHop.redis.get("#{request_id}:completed")).to eq "true"
      end
    end

    describe "#process" do
      it "sends the requests for left part of the routes and waits for results"
      it "sends the requests for right part of the routes and waits for results"
      it "analyses the results and sorts them by price"
    end
  end
end
