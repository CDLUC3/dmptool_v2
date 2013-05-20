require 'spec_helper'

describe "users/index" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :institution_id => 1,
        :email => "Email",
        :first_name => "First Name",
        :last_name => "Last Name",
        :token => "Token",
        :prefs => ""
      ),
      stub_model(User,
        :institution_id => 1,
        :email => "Email",
        :first_name => "First Name",
        :last_name => "Last Name",
        :token => "Token",
        :prefs => ""
      )
    ])
  end

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Token".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
