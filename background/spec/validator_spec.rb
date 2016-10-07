require_relative '../lib/hubhop'

describe HubHop::Validator do
  let(:request) { HubHop::Request.new }
  let(:form_data) { HubHopTestData.form_data }

  describe ".validate_input" do
    let(:form_data_past_dates) do
      data = HubHopTestData.form_data
      data[:from_date] = (Date.today - 3).strftime("%Y-%m-%d")
      data[:to_date] = (Date.today - 2).strftime("%Y-%m-%d")
      data
    end
    let(:form_data_future_dates) do
      data = HubHopTestData.form_data
      data[:from_date] = (Date.today + 365).strftime("%Y-%m-%d")
      data[:to_date] = (Date.today + 368).strftime("%Y-%m-%d")
      data
    end
    let(:form_data_misplaced_dates) do
      data = HubHopTestData.form_data
      data[:from_date] = (Date.today + 3).strftime("%Y-%m-%d")
      data[:to_date] = (Date.today + 1).strftime("%Y-%m-%d")
      data
    end
    let(:form_data_small_delay) do
      data = HubHopTestData.form_data
      data[:max_transit_time] = 2
      data
    end
    let(:form_data_large_delay) do
      data = HubHopTestData.form_data
      data[:max_transit_time] = 200
      data
    end
    let(:form_data_bad_airports) do
      data = HubHopTestData.form_data
      data[:from_place].push "LOL"
      data[:via_place].push "BEE"
      data
    end

    context "(validating input)" do
      it "returns a hash of errors" do
        expect(HubHop::Validator.validate_input form_data_past_dates).to be_a Hash
      end
      it "adds only errors that have messages for them" do
        err = HubHop::Validator.validate_input form_data_past_dates
        expect(err.size).to eq 2
      end
      it "adds an error if the dates are in the past" do
        err = HubHop::Validator.validate_input form_data_past_dates
        expect(err.keys).to include :from_date, :to_date
        expect(err[:from_date]).to include "The date is in the past"
        expect(err[:to_date]).to include "The date is in the past"
      end
      it "adds an error if the dates are way in the future" do
        err = HubHop::Validator.validate_input form_data_future_dates
        expect(err.keys).to include :from_date, :to_date
        expect(err[:from_date]).to include "The date is way in the future"
        expect(err[:to_date]).to include "The date is way in the future"
      end
      it "adds an error if the TO date is greater than FROM" do
        err = HubHop::Validator.validate_input form_data_misplaced_dates
        expect(err.keys).to include :to_date
        expect(err[:to_date]).to include "TO date must be later than FROM date"
      end
      it "adds an error if the transit time is too small" do
        err = HubHop::Validator.validate_input form_data_small_delay
        expect(err.keys).to include :max_transit_time
        expect(err[:max_transit_time]).
          to include "The transit time has to be at least 5 hours"
      end
      it "adds an error if the transit time is way too big" do
        err = HubHop::Validator.validate_input form_data_large_delay
        expect(err.keys).to include :max_transit_time
        expect(err[:max_transit_time]).
          to include "The transit time has to be at most 168 hours"
      end
      it "adds an error if the airport doesn't exist" do
        err = HubHop::Validator.validate_input form_data_bad_airports
        expect(err.keys).to include :from_place, :via_place
        expect(err[:from_place]).to include "Airport LOL doesn't exist"
        expect(err[:via_place]).to include "Airport BEE doesn't exist"
      end
    end
  end
end
