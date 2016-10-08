module HubHopHelper
  def fill_in_form_correctly
    fill_in "From Airports", with: "LED, DME"
    fill_in "Via Airports", with: "MUC"
    fill_in "To Airports", with: "BKK, AUS,LIS, HEL"

    fill_in "From date", with: "2017-05-19"
    fill_in "To date", with: "2017-05-23"
    fill_in "Max hours for transit in a hub", with: "36"
  end

  def setup_complete_results(req_id)
    HubHop::redis.set("#{req_id}:results", 
      {:cheapest_option=>
        {:from=>"SVO",
         :to=>"AUS",
         :via=>"FRA",
         :name=>"SVO->AUS",
         :legs=>
          [{:price=>8485.0,
            :deeplink=>
             "http://partners.api.skyscanner.net/apiservices/deeplink/",
            :agent=>{:name=>"Trip.ru"},
            :from=>{:code=>"SVO"},
            :to=>{:code=>"FRA"},
            :carrier=>{:name=>"Aeroflot"},
            :departure=>"2017-05-03T08:05:00+00:00",
            :arrival=>"2017-05-03T10:30:00+00:00"},
           {:price=>27729.59,
            :deeplink=>
             "http://partners.api.skyscanner.net/apiservices/deeplink/",
            :agent=>{:name=>"Thomas Cook Airlines"},
            :from=>{:code=>"FRA"},
            :to=>{:code=>"AUS"},
            :carrier=>{:name=>"Thomas Cook Airlines"},
            :departure=>"2017-05-04T16:25:00+00:00",
            :arrival=>"2017-05-04T20:55:00+00:00"}],
         :total_price=>36214.59}
      }.to_json)
    HubHop::redis.set "#{req_id}:completed", "true"
  end
end
