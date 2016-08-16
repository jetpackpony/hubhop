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

  factory :collected_data, class: Hash do

    initialize_with { attributes }
  end

  factory :cheapest_option, class: Hash do

    initialize_with { attributes }
  end
end
