module HubHopTestData
  def self.form_data
    {
      from_place: ["LED","DME","TLL"],
      via_place: ["BCN","MUC","FRA"],
      to_place: ["LIS","OPO","BKK"],
      from_date: "2016-12-01",
      to_date: "2016-12-03",
      max_transit_time: "30"
    }
  end

  def self.collector_input
    {
      from_place: ["LED","DME","TLL"],
      via_place: ["BCN","MUC","FRA"],
      to_place: ["LIS","OPO","BKK"],
      from_date: "2016-12-01",
      to_date: "2016-12-03",
      max_transit_time: "30",
      request_id: "testme_id"
    }
  end
end
