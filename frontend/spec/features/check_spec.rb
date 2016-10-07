describe "Check status of request", type: :feature do
  it "shows the input info of the request"
  it "shows the 'check again' button"

  context "When the request is not yet ready" do
    it "shows a 'wait a bit' message"
  end

  context "When the request is ready" do
    it "shows all the legs of the result route"
    it "shows a total price of the route"
  end

  context "When the request is not ready for a long time" do
    it "shows a message saying all is lost and we need to go to logs"
  end
end
