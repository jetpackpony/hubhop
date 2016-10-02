describe HubHop::LegLog do
  prefix = "[test_id:LED->DME_2016-12-02]"
  let(:leg_log) { HubHop::LegLog.new "test_id", "LED", "DME", "2016-12-02" }
  before do
    logger = instance_double Logger
    allow(logger).to receive(:info)
    allow(HubHop).to receive(:logger) { logger }
  end

  describe "#info" do
    it "passes log text with prefix to the global logger" do
      leg_log.info "Test me"
      expect(HubHop::logger).
        to have_received(:info).
        with("#{prefix} Test me").
        once
    end
  end
end

