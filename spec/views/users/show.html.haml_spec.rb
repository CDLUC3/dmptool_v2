require 'spec_helper'

describe "users/show" do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :institution_id => 1,
      :email => "Email",
      :first_name => "First Name",
      :last_name => "Last Name",
      :token => "Token",
      :prefs => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Email/)
    rendered.should match(/First Name/)
    rendered.should match(/Last Name/)
    rendered.should match(/Token/)
    rendered.should match(//)
  end
end
