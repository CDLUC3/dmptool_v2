require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'inst admin user' do 

	scenario 'institutional administrator creates an institution' do #, :js => true do

		logs_in_with "#{INST_ADMIN_USERNAME}", "#{INST_ADMIN_PASSWORD}", "#{INST_ADMIN_INSTITUTION_NAME}"

		expect(page).to have_link('My Dashboard')	
		expect(page).to have_link('DMP Templates')		
		expect(page).to have_link('Resources') 
		expect(page).to have_link('Institution Profile') 
		expect(page).to have_link('My Profile')	
		
		expect(page).to have_no_link('DMP Administration')	


		#INSTITUTION CREATION

		click_link 'Institution Profile'
		click_link 'Institution Hierarchy'
		click_link 'Add New Institution'
		@temp = Time.now
		fill_in 'institution_full_name', with: "institution_test_#{@temp}"
		page.select "#{INST_ADMIN_INSTITUTION_NAME}", :from => 'institution_parent_id'
		click_button 'Save Changes'
		expect(page).to have_content("Institution was successfully created.")
		
   	click_link("Back", :match => :first)
		click_link 'Institution Hierarchy'
		expect(page).to have_content("institution_test_#{@temp}")

		
	end

end