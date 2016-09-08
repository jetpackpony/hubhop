module HubHopTestData
  def self.form_data
    {
      from_place: ["LED","DME"],
      via_place: ["BCN","MUC"],
      to_place: ["LIS","OPO"],
      from_date: "2016-12-01",
      to_date: "2016-12-02",
      dates: ["2016-12-01","2016-12-02"],
      max_transit_time: "30"
    }
  end

  def self.collector_input
    {
      from_place: ["LED","DME"],
      via_place: ["BCN","MUC"],
      to_place: ["LIS","OPO"],
      from_date: "2016-12-01",
      to_date: "2016-12-02",
      dates: ["2016-12-01","2016-12-02"],
      max_transit_time: "30",
      request_id: "testme_id"
    }
  end
end
