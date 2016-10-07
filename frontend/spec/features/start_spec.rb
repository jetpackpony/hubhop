describe "Create search request", type: :feature do
  before do
    allow(HubHop::Search).to receive(:perform_async)
  end

  it "shows the form" do
    visit "/"
    expect(page).to have_content "Search request form"
    expect(page).to have_button "Submit"
  end

  context "when created request successfully" do
    it "redirects to the reqest/id page" do
      visit "/"
      fill_in_form_correctly
      click_button "Submit"
      expect(current_path).to match "^/request/[a-z]{8}"
    end
    it "displays a 'request created' flash message" do
      visit "/"
      fill_in_form_correctly
      click_button "Submit"
      expect(page).to have_content "New request created"
    end
  end

  context "when errors in form validation" do
    it "redirects back to the form page" do
      visit "/"
      fill_in_form_correctly
      fill_in "From Airports", with: "LOL"
      click_button "Submit"
      expect(current_path).to eq "/request/create"
    end
    it "shows an error if one of the airports doesn't exist" do
      visit "/"
      fill_in_form_correctly
      fill_in "From Airports", with: "LOL"
      click_button "Submit"
      expect(page).to have_css ".error", text: "Airport LOL doesn't exist"
    end
    it "shows an error if 'to' date is before 'from' date" do
      visit "/"
      fill_in_form_correctly
      fill_in "From date", with: "2017-05-24"
      click_button "Submit"
      expect(page).to have_css ".error", text:"TO date must be later than FROM date"
    end
    it "shows an error if the dates are too far in the future" do
      visit "/"
      fill_in_form_correctly
      fill_in "To date", with: "2018-05-24"
      click_button "Submit"
      expect(page).to have_css ".error", text:"The date is way in the future"
    end
  end

  context "failed to create a request" do
    before do
      r = instance_double HubHop::Request
      allow(r).to receive(:start_search) { raise "Some unexpected error" }
      allow(HubHop::Request).to receive(:new) { r }
    end

    it "displayes the raised error message" do
      visit "/"
      fill_in_form_correctly
      click_button "Submit"
      expect(current_path).to eq "/request/create"
      expect(page).to have_css ".error", text: "Some unexpected error"
    end
  end
end
