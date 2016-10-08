describe "Check status of request", type: :feature do
  before(:each) do
    allow(HubHop::Search).to receive(:perform_async)
    visit "/"
    fill_in_form_correctly
    click_button "Submit"
    @req_id = current_path.match(%r{/request/([a-z]{8})})[1]
  end

  it "shows the input info of the request" do
    expect(page).to have_content "LED, DME"
    expect(page).to have_content "MUC"
    expect(page).to have_content "BKK, AUS, LIS, HEL"
    expect(page).to have_content "2017-05-19"
    expect(page).to have_content "2017-05-23"
    expect(page).to have_content "36"
  end

  context "When the request is not yet ready" do
    it "shows the 'check again' button" do
      expect(page).to have_button "Check again"
    end
    it "shows a 'wait a bit' message" do
      expect(page).to have_content "The request is not yet complete"
    end
  end

  context "When the request is ready" do
    before(:each) do
      setup_complete_results @req_id
    end
    it "shows all the legs of the result route" do
      visit("/request/#{@req_id}")
      expect(page).to have_content "SVO -> FRA"
      expect(page).to have_content "8485.0"
      expect(page).to have_content "FRA -> AUS"
      expect(page).to have_content "27729.59"
    end
    it "shows a total price of the route" do
      visit("/request/#{@req_id}")
      expect(page).to have_content "36214.59"
    end
  end

  context "When the request is not ready for a long time" do
    it "shows a message saying all is lost and we need to go to logs"
  end
end
