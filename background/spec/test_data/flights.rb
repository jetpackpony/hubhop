module HubHopTestData
  def self.form_data
    {
      from_place: ["LED","DME"],
      via_place: ["BAR","MUN"],
      to_place: ["LIS","POR"],
      from_date: "2016-09-01",
      to_date: "2016-09-02",
      dates: ["2016-09-01","2016-09-02"],
      max_transit_time: "30"
    }
  end

  def self.collector_input
    {
      from_place: ["LED","DME"],
      via_place: ["BAR","MUN"],
      to_place: ["LIS","POR"],
      from_date: "2016-09-01",
      to_date: "2016-09-02",
      dates: ["2016-09-01","2016-09-02"],
      max_transit_time: "30",
      request_id: "testme_id"
    }
  end

  def self.test_legs
    [
      { from: "LED", to: "LIS", date: "2016-09-02" },
      { from: "DME", to: "BAR", date: "2016-09-02" },
      { from: "DME", to: "POR", date: "2016-09-01" },
      { from: "BAR", to: "POR", date: "2016-09-04" }
    ]
  end

  def self.polled_data
    {
      led_bar_2016_09_01: [
        { from: "LED", to: "BAR",
          departure: "2016-09-01 10:00:00", arrival: "2016-09-01 16:00:00",
          price: "3000", deeplink: "http://bookme.com/"},
        { from: "LED", to: "BAR",
          departure: "2016-09-01 23:00:00", arrival: "2016-09-02 03:00:00",
          price: "4500", deeplink: "http://bookme.com/"}
      ],
      led_mun_2016_09_02: [
        { from: "LED", to: "MUN",
          departure: "2016-09-02 14:00:00", arrival: "2016-09-02 20:00:00",
          price: "6000", deeplink: "http://bookme.com/"},
        { from: "LED", to: "MUN",
          departure: "2016-09-02 12:00:00", arrival: "2016-09-02 22:00:00",
          price: "6000", deeplink: "http://bookme.com/"}
      ],
      dme_bar_2016_09_01: [
        { from: "DME", to: "BAR",
          departure: "2016-09-01 14:00:00", arrival: "2016-09-01 18:00:00",
          price: "3500", deeplink: "http://bookme.com/"}
      ],
      dme_mun_2016_09_01: [
        { from: "DME", to: "MUN",
          departure: "2016-09-01 10:00:00", arrival: "2016-09-01 13:00:00",
          price: "8000", deeplink: "http://bookme.com/"},
        { from: "DME", to: "MUN",
          departure: "2016-09-01 12:00:00", arrival: "2016-09-01 15:00:00",
          price: "7000", deeplink: "http://bookme.com/"}
      ],
      mun_lis_2016_09_01: [
        { from: "MUN", to: "LIS",
          departure: "2016-09-01 13:00:00", arrival: "2016-09-01 23:00:00",
          price: "2000", deeplink: "http://bookme.com/"}
      ],
      mun_por_2016_09_01: [
        { from: "MUN", to: "POR",
          departure: "2016-09-01 23:00:00", arrival: "2016-09-02 06:00:00",
          price: "2500", deeplink: "http://bookme.com/"}
      ],
      mun_por_2016_09_02: [
        { from: "MUN", to: "POR",
          departure: "2016-09-02 14:00:00", arrival: "2016-09-02 20:00:00",
          price: "6000", deeplink: "http://bookme.com/"}
      ],
      mun_lis_2016_09_02: [
        { from: "MUN", to: "LIS",
          departure: "2016-09-02 23:00:00", arrival: "2016-09-03 04:00:00",
          price: "6000", deeplink: "http://bookme.com/"}
      ],
      bar_lis_2016_09_01: [
        { from: "BAR", to: "LIS",
          departure: "2016-09-01 02:00:00", arrival: "2016-09-01 09:00:00",
          price: "3500", deeplink: "http://bookme.com/"}
      ],
      bar_por_2016_09_01: [
        { from: "BAR", to: "POR",
          departure: "2016-09-01 10:00:00", arrival: "2016-09-01 13:00:00",
          price: "8000", deeplink: "http://bookme.com/"},
        { from: "BAR", to: "POR",
          departure: "2016-09-01 18:00:00", arrival: "2016-09-02 03:00:00",
          price: "8000", deeplink: "http://bookme.com/"}
      ],
      bar_lis_2016_09_02: [
        { from: "BAR", to: "LIS",
          departure: "2016-09-02 12:00:00", arrival: "2016-09-02 22:00:00",
          price: "7000", deeplink: "http://bookme.com/"}
      ],
      led_lis_2016_09_01: [
        { from: "LED", to: "LIS",
          departure: "2016-09-01 10:00:00", arrival: "2016-09-01 22:00:00",
          price: "3000", deeplink: "http://bookme.com/"},
        { from: "LED", to: "LIS",
          departure: "2016-09-01 12:00:00", arrival: "2016-09-01 15:00:00",
          price: "7000", deeplink: "http://bookme.com/"}
      ],
      led_por_2016_09_01: [
        { from: "LED", to: "POR",
          departure: "2016-09-01 23:00:00", arrival: "2016-09-02 03:00:00",
          price: "4500", deeplink: "http://bookme.com/"}
      ],
      dme_lis_2016_09_02: [
        { from: "DME", to: "LIS",
          departure: "2016-09-02 14:00:00", arrival: "2016-09-02 20:00:00",
          price: "6000", deeplink: "http://bookme.com/"},
        { from: "DME", to: "LIS",
          departure: "2016-09-02 12:00:00", arrival: "2016-09-02 22:00:00",
          price: "6000", deeplink: "http://bookme.com/"}
      ],
      dme_por_2016_09_01: [
        { from: "DME", to: "POR",
          departure: "2016-09-01 03:00:00", arrival: "2016-09-01 14:00:00",
          price: "3500", deeplink: "http://bookme.com/"}
      ],
      led_lis_2016_09_02: [
        { from: "LED", to: "LIS",
          departure: "2016-09-02 02:00:00", arrival: "2016-09-02 13:00:00",
          price: "8000", deeplink: "http://bookme.com/"}
      ]
    }
  end

  def self.cheapest_option
  end
end
