require_relative '../lib/hubhop'

describe HubHop::Request do
  let(:request) { HubHop::Request.new }

  after(:all) do
    HubHop::redis.flushdb
  end

  describe "#start" do
    let(:form_data) { HubHopTestData.form_data }
    let(:form_data_past_dates) do
      data = HubHopTestData.form_data
      data[:from_date] = (Date.today - 3).strftime("%Y-%m-%d")
      data[:to_date] = (Date.today - 2).strftime("%Y-%m-%d")
      data
    end
    let(:form_data_future_dates) do
      data = HubHopTestData.form_data
      data[:from_date] = (Date.today + 365).strftime("%Y-%m-%d")
      data[:to_date] = (Date.today + 368).strftime("%Y-%m-%d")
      data
    end
    let(:form_data_misplaced_dates) do
      data = HubHopTestData.form_data
      data[:from_date] = (Date.today + 3).strftime("%Y-%m-%d")
      data[:to_date] = (Date.today + 1).strftime("%Y-%m-%d")
      data
    end
    let(:form_data_small_delay) do
      data = HubHopTestData.form_data
      data[:max_transit_time] = 2
      data
    end
    let(:form_data_large_delay) do
      data = HubHopTestData.form_data
      data[:max_transit_time] = 200
      data
    end

    let(:redis_record) { HubHop::redis.get("#{request.request_id}:request") }

    before do
      allow(HubHop::Search).to receive(:perform_async)
    end

    context "(validating input)" do
      it "raises an error if the dates are in the past" do
        expect {
          request.start_search form_data_past_dates
        }.to raise_error "At least one of the dates is in the past"
      end
      it "raises an error if the dates are way in the future" do
        expect {
          request.start_search form_data_future_dates
        }.to raise_error "At least one of the dates is in the future"
      end
      it "raises an error if the TO date is greater than FROM" do
        expect {
          request.start_search form_data_misplaced_dates
        }.to raise_error "TO date must be at least the FROM date"
      end

      it "raises an error if the transit time is too small" do
        expect {
          request.start_search form_data_small_delay
        }.to raise_error "The transit time has to be at least 5 hours"
      end
      it "raises an error if the transit time is way too big" do
        expect {
          request.start_search form_data_large_delay
        }.to raise_error "The transit time has to be at most 168 hours"
      end

      it "raises an error if the airport doesn't exist"
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
  end
end
