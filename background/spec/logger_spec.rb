def get_log_device(log)
  log.instance_variable_get(:@logdev).instance_variable_get(:@dev)
end

describe "HubHop::logger" do
  before(:each) do
    @old_env = ENV
  end
  after(:each) do
    ENV["LOGS_OUTPUT"] = @old_env["LOGS_OUTPUT"]
  end

  context "when output is STDOUT" do
    before(:each) do
      ENV["LOGS_OUTPUT"] = "STDOUT"
    end
    it "writes to std output" do
      expect(get_log_device HubHop::new_logger).to eq STDOUT
    end
  end

  context "when output is file" do
    before(:each) do
      ENV["LOGS_OUTPUT"] = "file:log/testing.log"
      @file = File.expand_path("../../log/testing.log", __FILE__)
    end
    it "creates a file" do
      expect(get_log_device(HubHop::new_logger).path).to eq @file
    end
  end
end
