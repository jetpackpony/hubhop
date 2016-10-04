describe "HubHop app", type: :feature do
  it "shows the form" do
    visit "/"
    expect(page).to have_content "Search request form"
    expect(page).to have_button "Submit"
  end

  context "errors in form validation"
  context "failed to create a request"
  context "created request successfully"
end
