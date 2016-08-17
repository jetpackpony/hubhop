require_relative '../lib/hubhop'

describe HubHop::Collector do
  let(:form_data) { FactoryGirl.build :form_data }
  let(:collected_data) { FactoryGirl.build :collected_data }
  let(:collector) { HubHop::Collector.new form_data }
  before do
    allow(HubHop::SkyScannerAPI).to receive(:create_session)
  end

  describe "#collect" do
    it "creates a search session for every leg of the trip" do
      collector.collect
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        exactly(32).times
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("LED", "BAR", "2016-09-01")
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("LED", "LIS", "2016-09-02")
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("DME", "BAR", "2016-09-02")
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("DME", "POR", "2016-09-01")
      expect(HubHop::SkyScannerAPI).
        to have_received(:create_session).
        with("BAR", "POR", "2016-09-04")
    end
    it "creates a worker to poll each of the sessions"
    it "waits for all the workers to finish"
    it "returns the composed result of the api requests" do
      skip
      expect(collector.collect[:flights].count).to eq collected_data[:flights].count
    end
  end
end
