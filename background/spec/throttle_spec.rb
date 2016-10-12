require File.expand_path("../../lib/throttle", __FILE__)

describe HubHop::SkyScannerAPI::Throttle do
  let(:throttle) { HubHop::SkyScannerAPI::Throttle.new 3, 1 }
  before do
    allow(HubHop::SkyScannerAPI::Throttle).to receive(:sleeep)
  end
  describe "#delay" do
    it "executes the block right away if the queue is empty" do
      expect{ |b| throttle.delay &b }.to yield_control
      expect(HubHop::SkyScannerAPI::Throttle).
        not_to have_received(:sleeep)
    end
    it "waits till the next period if the queue is full" do
      4.times do
        throttle.delay { false }
      end
      expect(HubHop::SkyScannerAPI::Throttle).
        to have_received(:sleeep).
        at_least(:once)
    end
  end
end
