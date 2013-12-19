require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'inst admin user' do 

	scenario 'institutional administrator creates and removes an institution', :js => true do

		#logs_in_with "#{INST_ADMIN_USERNAME}", "#{INST_ADMIN_PASSWORD}", "#{INST_ADMIN_INSTITUTION_NAME}"
		logs_in_with "instadmin123", "instadmin123", "Test Institution"

		expect(page).to have_link('My Dashboard')
		expect(page).to have_link('My Profile')		
		expect(page).to have_link('DMP Templates')		
		expect(page).to have_link('Resources') 
		expect(page).to have_link('Institution Profile') 
		
		expect(page).to have_no_link('DMP Administration')	


		#INSTITUTION PROFILE

		#within('#quick_dashboard') do
			click_link 'Institution Profile'
		#end
		# within('#dmp_templates') do
  # 		expect(page).to have_content("Visibility")
		# end
		# expect(page).to have_content("DMP TEMPLATE EDITORS")

		# #create new DMP template
		# click_button 'Create New Template'
		# expect(page).to have_content("Create New DMP")
		# click_button 'create_new_template'
		# expect(page).to have_content("DMP TEMPLATE OVERVIEW")
		# expect(page).to have_field("institution_name", :disabled => true)
		# expect(page).to have_content("Test Institution")
		# @temp = Time.now.to_s
		# fill_in 'requirements_template_name', with: "test-template-1-public_#{@temp}"
		# page.choose 'public'
		# click_button 'Save Changes'
		# expect(page).to have_content("Requirements template was successfully created.")

		# #delete DMP template just created
		# within('#quick_dashboard') do
		# 	click_link 'DMP Templates'
		# end
		# click_link 'view_all_templates'	
		# #find('#test-template-1-public').hover.find('.template-links').hover.find('.delete').click
		# #click_button 'Delete'	
		# click_link "test-template-1-public_#{@temp}"
		# click_link "Delete Template"
		
		# find('.confirm').click
		
		
		# click_link 'view_all_templates'	
		# expect(page).to have_no_content("test-template-1-public_#{@temp}")

		# #GRANT TEMPLATE EDITOR ROLE

		
	end

end