module HubHopHelper
  def fill_in_form_correctly
    fill_in "From Airports", with: "LED, DME"
    fill_in "Via Airports", with: "MUC"
    fill_in "To Airports", with: "BKK, AUS,LIS, HEL"

    fill_in "From date", with: "2017-05-19"
    fill_in "To date", with: "2017-05-23"
    fill_in "Max hours for transit in a hub", with: "36"
  end
end
