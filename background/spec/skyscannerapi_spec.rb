describe HubHop::SkyScannerAPI do
  context "(stabbed requests to void)" do
    before do
      allow(HubHop::SkyScannerAPI).to receive(:send_request)
    end

    describe ".perform_request" do
      it "sends a GET request"
    end

    describe ".post" do
      it "sends a POST request"
    end
  end
end
