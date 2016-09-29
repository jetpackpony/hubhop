describe HubHop::LegLog do
  include HubHop::RedisConnect

  req_id = "test_id"
  record_key = "test_id:log:LED_DME_2016-12-02"
  record_key1 = "test_id:log:BCN_MUC_2016-12-02"
  master_record_key = "test_id:log"
  let(:log) do
    HubHop::LegLog.new "test_id", "LED", "DME", "2016-12-02"
  end
  let(:log1) do
    HubHop::LegLog.new "test_id", "BCN", "MUC", "2016-12-02"
  end
  let(:log_record) { redis.get record_key }
  let(:log_record1) { redis.get record_key1 }
  let(:master_log_record) { redis.get master_record_key }

  before(:all) do
    redis.del record_key
    redis.del record_key1
    redis.del master_record_key
  end
  after(:each) do
    redis.del record_key
    redis.del record_key1
    redis.del master_record_key
  end

  describe "#text" do
    it "returns the text of the log" do
      log.log "This is a test", :info
      expect(log.text).to include "This is a test"
    end
    it "returns an empty string if the log is empty" do
      expect(log.text).to eq ""
    end
  end

  describe "#log" do
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

  describe ".merge_logs" do
    it "creates a new record with all the records combined" do
      log.log "This is a test", :info
      log1.log "This is another test", :info
      HubHop::LegLog.merge_logs req_id, [log, log1]

      expect(master_log_record).to include "This is a test"
      expect(master_log_record).to include "This is another test"
    end
    it "deletes all the individual logs' records" do
      log.log "This is a test", :info
      log1.log "This is another test", :info
      HubHop::LegLog.merge_logs req_id, [log, log1]

      expect(log_record).to eq nil
      expect(log_record1).to eq nil
    end
  end
end

