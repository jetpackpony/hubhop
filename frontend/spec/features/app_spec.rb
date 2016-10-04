describe "HubHop app", type: :feature do
  it "shows the form" do
    visit "/"
    expect(page).to have_content "Hello, world"
  end
end
