describe HubHop::LegLog do
  include HubHop::RedisConnect

  describe "#log" do
    record_key = "test_id:log:LED_DME_2016-12-02"
    let(:log) do
      HubHop::LegLog.new "test_id", "LED", "DME", "2016-12-02"
    end
    let(:log_record) { redis.get record_key }

    before(:all) do
      redis.del record_key
    end
    after(:each) do
      redis.del record_key
    end

    it "adds a log message to a DB" do
      log.log "This is a test", :info
      expect(log_record).to include "This is a test"
    end
    it "appends a message to the log in the DB" do
      log.log "This is a test", :info
      log.log "This is another test", :info
      expect(log_record).to include "This is a test"
      expect(log_record).to include "This is another test"
    end
    it "adds a stack trace if the message is an error" do
      log.log "This is an error", :error
      expect(log_record).to match /hubhop_leg_log\.rb.+`log'/
    end
    it "does not add a stack trace if the message is an info" do
      log.log "This is an info", :info
      expect(log_record).not_to match /hubhop_leg_log\.rb.+`log'/
    end
  end
end

