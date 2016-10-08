require_relative '../lib/hubhop'

describe HubHop::Request do
  let(:request) { HubHop::Request.new }
  let(:form_data) { HubHopTestData.form_data }
  let(:form_data_past_dates) do
    data = HubHopTestData.form_data
    data[:from_date] = (Date.today - 3).strftime("%Y-%m-%d")
    data[:to_date] = (Date.today - 2).strftime("%Y-%m-%d")
    data
  end

  after(:all) do
    HubHop::redis.flushdb
  end

  describe "#start" do
    let(:redis_record) { HubHop::redis.get("#{request.request_id}:request") }

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
    it "raises an error if the data doesn't pass validation" do
      expect {
        request.start_search form_data_past_dates
      }.to raise_error "Input data didn't pass validation"
    end
  end

  describe "#check" do
    context ">> if request processing not completed," do
      it "returns false" do
        HubHop::redis.set "#{request.request_id}:completed", "false"
        expect(request.check).to be false
      end
    end

    context ">> request processing has completed," do
      let(:results) { { results: true }.to_json }
      it "returns hash with results" do
        HubHop::redis.set "#{request.request_id}:completed", "true"
        HubHop::redis.set "#{request.request_id}:results", results
        expect(request.check).to eq results
      end
    end

    context ">> request id doesn't exist," do
      it "raises an error" do
        expect {
          request.check
        }.to raise_error "This request id doesn't exist"
      end
    end
  end

  describe "#request" do
    it "returns the input request data of the request" do
      req = request
      req.start_search form_data
      expect(req.request).to eq form_data
    end
    it "raises an error if the request wasn't started" do
      expect{request.request}.to raise_error "Failed to json.parse request data"
    end
  end
end
