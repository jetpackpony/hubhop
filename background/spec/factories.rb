FactoryGirl.define do
  factory :form_data, class: Hash do
    from_place []
    via_place []
    to_place []
    from_date ""
    to_date ""
    max_transit_time ""

    initialize_with { attributes }
  end
end
