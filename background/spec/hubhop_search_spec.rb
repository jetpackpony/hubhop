require_relative "../lib/hubhop"

describe HubHop::Search do
  let(:form_data) { FactoryGirl.build :form_data }
  let(:collected_data) { FactoryGirl.build :collected_data }
  let(:cheapest_option) { FactoryGirl.build :cheapest_option }
  let(:request_id) { "testme" }

  describe "#perform" do
    before do
      Redis.new.set "#{request_id}:request", { request_data: form_data }.to_json
      collector = instance_double(HubHop::Collector)
      allow(collector).to receive(:collect) { collected_data }
      allow(HubHop::Collector).to receive(:new) { collector }

      analyser = instance_double(HubHop::Analyser)
      allow(analyser).to receive(:get_cheapest) { cheapest_option }
      allow(HubHop::Analyser).to receive(:new) { analyser }

      HubHop::Search.new.perform request_id
    end

    it "collects the information about all the flights" do
      expect(HubHop::Collector.new form_data).
        to have_received(:collect).
        once
    end
    it "chooses the cheapest route option" do
      expect(HubHop::Analyser.new collected_data).
        to have_received(:get_cheapest).
        once
    end
    it "writes the results to the database" do
      expect(Redis.new.get "#{request_id}:results").
        to eq({ cheapest_option: cheapest_option }.to_json)
    end
    it "marks the request in the database as completed" do
      expect(Redis.new.get "#{request_id}:completed").to eq true.to_json

    end
  end
end
