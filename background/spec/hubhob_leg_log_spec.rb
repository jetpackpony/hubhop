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
      log.log "This is a test"
      expect(log_record).to include "This is a test"
    end
    it "appends a message to the log in the DB" do
      log.log "This is a test"
      log.log "This is another test"
      expect(log_record).to include "This is a test"
      expect(log_record).to include "This is another test"
    end
  end
end

