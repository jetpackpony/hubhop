require_relative '../lib/hubhop'
require 'byebug'

describe HubHop do
  describe HubHop::RequestWorker do
    describe ".perform" do
      let(:worker) { HubHop::RequestWorker.new }
      let(:req_id) { "==request_id==" }
      let(:request_double) do
        double = instance_double HubHop::Request
        allow(double).to receive(:run)
        double
      end

      before do
        allow(HubHop::Request).to receive(:new) { request_double }
      end

      it "creates the request object with request id" do
        worker.perform req_id
        expect(HubHop::Request).to have_received(:new).with(req_id).once
      end

      it "runs the request" do
        worker.perform req_id
        expect(request_double).to have_received(:run).once
      end
    end
  end
end
