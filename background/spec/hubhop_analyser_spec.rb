require_relative '../lib/hubhop'

describe HubHop::Analyser do
  let(:analyser) { 
    HubHop::Analyser.new HubHopTestData.form_data, HubHopTestData.collected_data 
  }

  describe "#cheapest" do
    it "returns the cheapest route option from generated hash" do
      expect(analyser.cheapest).to eq HubHopTestData.cheapest_option
    end
  end
end
