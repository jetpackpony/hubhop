describe HubHop::SkyScannerAPI do
  before do
    allow(HubHop::SkyScannerAPI).to receive(:wait_a_bit)
    allow(HubHop::SkyScannerAPI).to receive(:wait_for_poll_request_limit_to_shift)
    allow(HubHop::SkyScannerAPI).to receive(:wait_for_create_request_limit_to_shift)
    allow(HubHop::SkyScannerAPI).to receive(:time_passed?) { false }
  end

  context "(stabbed requests to void)" do
    before do
      allow(HubHop::SkyScannerAPI).to receive(:send_request)
    end

    describe ".perform_request" do
      it "sends a request no more than POLL_SESSION_LIMIT times per minute" do
        (HubHop::SkyScannerAPI::POLL_SESSION_LIMIT + 5).times do
          HubHop::SkyScannerAPI::perform_request "http://google.com/"
        end
        expect(HubHop::SkyScannerAPI).
          to have_received(:wait_for_poll_request_limit_to_shift).
          at_least(:once)
      end
    end

    describe ".post" do
      it "sends a request no more than CREATE_SESSION_LIMIT times per minute" do
        (HubHop::SkyScannerAPI::CREATE_SESSION_LIMIT + 5).times do
          HubHop::SkyScannerAPI::post "http://google.com/", {}, {}
        end
        expect(HubHop::SkyScannerAPI).
          to have_received(:wait_for_create_request_limit_to_shift).
          at_least(:once)
      end
    end
  end
end
