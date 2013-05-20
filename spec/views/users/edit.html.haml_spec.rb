require 'spec_helper'

describe "users/edit" do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :institution_id => 1,
      :email => "MyString",
      :first_name => "MyString",
      :last_name => "MyString",
      :token => "MyString",
      :prefs => ""
    ))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", user_path(@user), "post" do
      assert_select "input#user_institution_id[name=?]", "user[institution_id]"
      assert_select "input#user_email[name=?]", "user[email]"
      assert_select "input#user_first_name[name=?]", "user[first_name]"
      assert_select "input#user_last_name[name=?]", "user[last_name]"
      assert_select "input#user_token[name=?]", "user[token]"
      assert_select "input#user_prefs[name=?]", "user[prefs]"
    end
  end
end
