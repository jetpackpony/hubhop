FactoryGirl.define do
  factory :form_data, class: Hash do
    from_place ["LED","DME"]
    via_place ["BAR","MUN"]
    to_place ["LIS","POR"]
    from_date "2016-09-01"
    to_date "2016-09-02"
    dates ["2016-09-01","2016-09-02"]
    max_transit_time "30"

    initialize_with { attributes }
  end

  factory :collected_data, class: Hash do
    flights [
      { from: "LED", to: "BAR",
        departure: "2016-09-01 10:00:00", arrival: "2016-09-01 16:00:00",
        price: "3000", deeplink: "http://bookme.com/"},
      { from: "LED", to: "BAR",
        departure: "2016-09-01 23:00:00", arrival: "2016-09-02 03:00:00",
        price: "4500", deeplink: "http://bookme.com/"},
      { from: "LED", to: "MUN",
        departure: "2016-09-02 14:00:00", arrival: "2016-09-02 20:00:00",
        price: "6000", deeplink: "http://bookme.com/"},
      { from: "LED", to: "MUN",
        departure: "2016-09-02 12:00:00", arrival: "2016-09-02 22:00:00",
        price: "6000", deeplink: "http://bookme.com/"},
      { from: "DME", to: "BAR",
        departure: "2016-09-01 14:00:00", arrival: "2016-09-01 18:00:00",
        price: "3500", deeplink: "http://bookme.com/"},
      { from: "DME", to: "MUN",
        departure: "2016-09-01 10:00:00", arrival: "2016-09-01 13:00:00",
        price: "8000", deeplink: "http://bookme.com/"},
      { from: "DME", to: "MUN",
        departure: "2016-09-01 12:00:00", arrival: "2016-09-01 15:00:00",
        price: "7000", deeplink: "http://bookme.com/"},
      { from: "MUN", to: "LIS",
        departure: "2016-09-01 13:00:00", arrival: "2016-09-01 23:00:00",
        price: "2000", deeplink: "http://bookme.com/"},
      { from: "MUN", to: "POR",
        departure: "2016-09-01 23:00:00", arrival: "2016-09-02 06:00:00",
        price: "2500", deeplink: "http://bookme.com/"},
      { from: "MUN", to: "POR",
        departure: "2016-09-02 14:00:00", arrival: "2016-09-02 20:00:00",
        price: "6000", deeplink: "http://bookme.com/"},
      { from: "MUN", to: "LIS",
        departure: "2016-09-02 23:00:00", arrival: "2016-09-03 04:00:00",
        price: "6000", deeplink: "http://bookme.com/"},
      { from: "BAR", to: "LIS",
        departure: "2016-09-01 02:00:00", arrival: "2016-09-01 09:00:00",
        price: "3500", deeplink: "http://bookme.com/"},
      { from: "BAR", to: "POR",
        departure: "2016-09-01 10:00:00", arrival: "2016-09-01 13:00:00",
        price: "8000", deeplink: "http://bookme.com/"},
      { from: "BAR", to: "POR",
        departure: "2016-09-01 18:00:00", arrival: "2016-09-02 03:00:00",
        price: "8000", deeplink: "http://bookme.com/"},
      { from: "BAR", to: "LIS",
        departure: "2016-09-02 12:00:00", arrival: "2016-09-02 22:00:00",
        price: "7000", deeplink: "http://bookme.com/"},
      { from: "LED", to: "LIS",
        departure: "2016-09-01 10:00:00", arrival: "2016-09-01 22:00:00",
        price: "3000", deeplink: "http://bookme.com/"},
      { from: "LED", to: "POR",
        departure: "2016-09-01 23:00:00", arrival: "2016-09-02 03:00:00",
        price: "4500", deeplink: "http://bookme.com/"},
      { from: "DME", to: "LIS",
        departure: "2016-09-02 14:00:00", arrival: "2016-09-02 20:00:00",
        price: "6000", deeplink: "http://bookme.com/"},
      { from: "DME", to: "LIS",
        departure: "2016-09-02 12:00:00", arrival: "2016-09-02 22:00:00",
        price: "6000", deeplink: "http://bookme.com/"},
      { from: "DME", to: "POR",
        departure: "2016-09-01 03:00:00", arrival: "2016-09-01 14:00:00",
        price: "3500", deeplink: "http://bookme.com/"},
      { from: "LED", to: "LIS",
        departure: "2016-09-02 02:00:00", arrival: "2016-09-02 13:00:00",
        price: "8000", deeplink: "http://bookme.com/"},
      { from: "LED", to: "LIS",
        departure: "2016-09-01 12:00:00", arrival: "2016-09-01 15:00:00",
        price: "7000", deeplink: "http://bookme.com/"},
    ]

    initialize_with { attributes }
  end

  factory :cheapest_option, class: Hash do

    initialize_with { attributes }
  end
end
