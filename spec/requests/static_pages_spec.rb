require 'spec_helper'

describe "StaticPages" do

  # describe "Home page" do
  # 	it "should have the content 'Data Management Plan Tool'" do
  # 		visit root_path
  # 		expect(page).to have_content('Data Management Plan Tool')
  # 	end
  # end

  describe "About page" do
    it "should have  the content 'About the DMPTool' " do
      visit about_path
      expect(page).to have_content('About the DMPTool')
    end
  end

  describe "Help page" do
    it "should have the content 'DMPTool Guide' " do
      visit help_path
      expect(page).to have_content('DMPTool Guide')
    end
  end

  describe "Help page" do
    it "should have the content 'Contact Us' " do
      visit contact_path
      expect(page).to have_content('Contact Us')
    end
  end
 end
