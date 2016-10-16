require_relative '../lib/hubhop'

describe HubHop::FlightGraph do
  let(:graph) {
    HubHop::FlightGraph.new(
      HubHopTestData.collected_data,
      HubHopTestData.form_data[:from_place],
      HubHopTestData.form_data[:to_place],
      HubHopTestData.form_data[:max_transit_time]
    )
  }

  let(:muc_date) { DateTime.parse("2016-12-01T11:20:00+00:00") }
  let(:muc_date_early) { DateTime.parse("2016-12-01T12:25:00+00:00") }
  let(:muc_date_possible) { DateTime.parse("2016-12-01T19:55:00+00:00") }
  let(:muc_date_late) { DateTime.parse("2016-12-04T16:10:00+00:00") }

  let(:bcn_date) { DateTime.parse("2016-12-01T06:45:00+00:00") }
  let(:bcn_date_1) { DateTime.parse("2016-12-02T08:45:00+00:00") }

  let(:led_opo_legs) { HubHopTestData.led_opo_legs }
  let(:dme_lis_legs) { HubHopTestData.dme_lis_legs }
  let(:cheapest_route) { HubHopTestData.cheapest_option }

  describe "#load_flights" do
    it "creates an edge for each flight in the list" do
      edge = graph.get_edge ["LED", false, :from], ["MUC", muc_date, :to]
      expect(graph.edges.count).to eq 157
      expect(edge).to be_truthy
      expect(edge[:price]).to eq 7395.0
      expect(edge[:start]).to eq true
      expect(edge[:finish]).to eq false
    end
    it "creates a vertex for each of the start places" do
      vert = graph.get_vertex "LED", false, :from
      expect(vert).to be_truthy
      expect(vert[:start]).to be true
      expect(vert[:finish]).to be false
    end
    it "creates a vertex for each of the finish places" do
      vert = graph.get_vertex "LIS", false, :to
      expect(vert).to be_truthy
      expect(vert[:finish]).to be true
      expect(vert[:start]).to be false
    end
    it "creates a vertex for each departure from a hub" do
      vert = graph.get_vertex "MUC", muc_date, :from
      expect(vert).to be_truthy
      expect(vert[:finish]).to be false
      expect(vert[:start]).to be false

      vert = graph.get_vertex "BCN", bcn_date, :from
      expect(vert).to be_truthy
      expect(vert[:finish]).to be false
      expect(vert[:start]).to be false
    end
    it "creates a vertex for every arrival to a hub" do
      vert = graph.get_vertex "MUC", muc_date, :to
      expect(vert).to be_truthy
      expect(vert[:finish]).to be false
      expect(vert[:start]).to be false
    end
    it "does not create a vertex for arrival where it doesn't exist" do
      vert = graph.get_vertex "BCN", bcn_date, :to
      expect(vert).to be_falsy
    end
    it "keeps the lowest price in case of the parallel edges" do
      edge = graph.get_edge ["DME", false, :from], ["BCN", bcn_date_1, :to]
      expect(edge[:price]).to eq 6892.38
      expect(edge[:flight_id]).to eq 10
    end
  end

  describe "#build_connections" do
    it "creates an edge for every possible connection" do
      edge = graph.get_edge(
        ["MUC", muc_date, :to], ["MUC", muc_date_possible, :from]
      )
      expect(edge).to be_truthy
      expect(edge[:price]).to eq 0
      expect(edge[:start]).to eq false
      expect(edge[:finish]).to eq false
    end
    it "does not create edges for impossible connections" do
      edge = graph.get_edge(
        ["MUC", muc_date, :to], ["MUC", muc_date_early, :from]
      )
      expect(edge).to be_falsy
    end
    it "does not create edges for connections not fitting in transit time" do
      edge = graph.get_edge(
        ["MUC", muc_date, :to], ["MUC", muc_date_late, :from]
      )
      expect(edge).to be_falsy
    end
  end

  describe "#run_dijkstra" do
    it "creates the list of all start->finish routes" do
      expect(graph.routes.keys).
        to include *["LED->LIS", "DME->LIS", "LED->OPO", "DME->OPO"]
    end
    it "only includes start->finish routes in the routes list" do
      expect(graph.routes.keys).
        not_to include *["LED->BCN", "DME->MUC", "MUC->LIS", "BCN->OPO"]
    end
    it "chooses the correct min price for each route in the list" do
      expect(graph.routes["LED->LIS"][:total_price]).to eq 10950.39
      expect(graph.routes["DME->OPO"][:total_price]).to eq 10334.39
    end
    it "adds the list of flights that are the legs of the route" do
      expect(graph.routes["LED->OPO"][:legs]).to eq led_opo_legs
      expect(graph.routes["DME->LIS"][:legs]).to eq dme_lis_legs
    end
    it "adds from point to the route" do
      expect(graph.routes["LED->OPO"][:from]).to eq "LED"
    end
    it "adds from point to the route" do
      expect(graph.routes["DME->LIS"][:to]).to eq "LIS"
    end
    it "adds via point to the route" do
      expect(graph.routes["LED->OPO"][:via]).to eq "MUC"
    end
  end

  describe "#cheapest" do
    it "returns the cheapest route" do
      expect(graph.cheapest).to eq cheapest_route
    end
  end
end
