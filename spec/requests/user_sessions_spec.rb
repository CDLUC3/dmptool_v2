require 'spec_helper'

describe "UserSessions" do
  subject { page }

  describe "login page" do
    before { visit login_path }

    it { should have_content('Login') }

    describe "with invalid information" do
      before { click_button "Login" }

      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { visit login_path }
        it { should_not have_error_message }
      end
    end

    describe "with valid information" do
      describe "and a new user" do
        before do
          fill_in "Username", with: 'TestUser'
          fill_in "Password", with: 'Password12345'
          click_button 'Login'
        end

        it { should_not have_error_message }
        it { should have_success_message('New user created.') }
      end

      describe "and a returning user" do

        before do
          fill_in "Username", with: 'TestUser'
          fill_in "Password", with: 'Password12345'
          click_button 'Login'
          fill_in "Username", with: 'TestUser'
          fill_in "Password", with: 'Password12345'
          click_button 'Login'
        end

        it { should_not have_error_message }
        it { should have_success_message('User was found.') }

      end
      end
  end
end
