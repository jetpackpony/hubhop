require_relative 'test_data/flights'
require_relative "../lib/hubhop"

describe HubHop::Search do
  include HubHop::RedisConnect

  let(:form_data) { HubHopTestData.form_data }
  let(:collected_data) { HubHopTestData.collected_data }
  let(:cheapest_option) { HubHopTestData.cheapest_option }
  let(:request_id) { "testme" }
  let(:create_flihgt_graph) {
    HubHop::FlightGraph.new(
      collected_data, form_data[:from_place], form_data[:to_place], form_data[:max_transit_time]
    )
  }
  let(:perfrom_search) { HubHop::Search.new.perform request_id }
  let(:unfiltered_data) { HubHopTestData::collected_data_unfiltered }

  describe "#perform" do
    before do
      redis.set "#{request_id}:request", { request_data: form_data }.to_json
      collector = instance_double(HubHop::Collector)
      allow(collector).to receive(:collect) { unfiltered_data }
      allow(HubHop::Collector).to receive(:new) { collector }

      flight_graph = instance_double(HubHop::FlightGraph)
      allow(flight_graph).to receive(:cheapest) { cheapest_option }
      allow(HubHop::FlightGraph).to receive(:new) { flight_graph }
    end

    after(:each) do
      redis.del "#{request_id}:collected_flights"
      redis.del "#{request_id}:completed"
      redis.del "#{request_id}:results"
      redis.del "#{request_id}:request"
    end

    context "(the flights are not yet collected)" do
      it "collects the information about all the flights" do
        perfrom_search
        expect(HubHop::Collector.new form_data).
          to have_received(:collect).
          once
      end
      it "records the inforamtion about flights in the DB" do
        perfrom_search
        expect(redis.get "#{request_id}:collected_flights").
          to eq(unfiltered_data.to_json)
      end
    end

    context "(the flights are already collected)" do
      before do
        redis.set(
          "#{request_id}:collected_flights",
          unfiltered_data.to_json
        )
      end
      it "does not call the collector" do
        perfrom_search
        expect(HubHop::Collector).
          not_to have_received(:new)
      end
    end

    it "chooses the cheapest route option" do
      perfrom_search
      expect(create_flihgt_graph).
        to have_received(:cheapest).
        once
    end
    it "writes the results to the database" do
      perfrom_search
      expect(redis.get "#{request_id}:results").
        to eq({ cheapest_option: cheapest_option }.to_json)
    end
    it "marks the request in the database as completed" do
      perfrom_search
      expect(redis.get "#{request_id}:completed").to eq true.to_json
    end
    it "creates the flight graph with zero results filtered out" do
      perfrom_search
      expect(HubHop::FlightGraph).
        to have_received(:new).with(
          collected_data, form_data[:from_place], form_data[:to_place], form_data[:max_transit_time]
        ).once
    end
  end
end
