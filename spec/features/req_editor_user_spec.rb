require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'req editor user' do 

	scenario 'scenarios', :js => true do

		logs_in_with "#{REQ_EDITOR_USERNAME}", "#{REQ_EDITOR_PASSWORD}", "#{REQ_EDITOR_INSTITUTION_NAME}"

		expect(page).to have_link('My Dashboard')
		expect(page).to have_link('My Profile')		
		expect(page).to have_link('DMP Templates')		

		expect(page).to have_no_link('Resources') 
		expect(page).to have_no_link('Institution Profile') 
		expect(page).to have_no_link('DMP Administration')	

		#MY DASHBOARD 

		#My Dashboard sections are present
		click_link 'My Dashboard'
		expect(page).to have_content("OVERVIEW")
		expect(page).to have_content("DMP Templates")

		expect(page).to have_no_content("DMPs For My Review")
		expect(page).to have_no_content("Resource Templates")

		

		#DMP TEMPLATE

		within('#quick_dashboard') do
			click_link 'DMP Templates'
		end
		within('#dmp_templates') do
  		expect(page).to have_content("Visibility")
		end
		expect(page).to have_content("DMP TEMPLATE EDITORS")

		#create new DMP template
		click_button 'Create New Template'
		expect(page).to have_content("Create New DMP")
		click_button 'create_new_template'
		expect(page).to have_content("DMP TEMPLATE OVERVIEW")
		expect(page).to have_field("institution_name", :disabled => true)
		expect(page).to have_content("Test Institution")
		fill_in 'requirements_template_name', with: 'test-template-1-public'
		page.choose 'public'
		click_button 'Save Changes'
		expect(page).to have_content("Requirements template was successfully created.")

		#delete DMP template just created
		within('#quick_dashboard') do
			click_link 'DMP Templates'
		end
		click_link 'view_all_templates'
		
		#find('#test-template-1-public').hover.find('.template-links').hover.find('.delete').click
		#click_button 'Delete'	
		find('#test-template-1-public').click
		#find('#delete_template').click
			
		
		click_link "Delete Template"
		click_link 'Delete'
		
	end

end
