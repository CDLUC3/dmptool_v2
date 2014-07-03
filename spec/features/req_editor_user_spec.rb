require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'req editor user' do 

	scenario 'requirement editor creates a requirement group' , :js => true do

		logs_in_with "#{REQ_EDITOR_USERNAME}", "#{REQ_EDITOR_PASSWORD}", "#{REQ_EDITOR_INSTITUTION_NAME}"
		within('#quick_dashboard') do
			click_link 'DMP Templates'
		end
		click_link 'Institution only'
		find('#top_level_test_inst_template').hover
		find('.details').click
		expect(page).to have_content "op_level_test_inst_template"
		click_link 'Add Group'
		@temp = Time.now.to_s
		fill_in "requirement_text_brief", with: "new_group_#{@temp}"
		within('.buttons') do
			click_button 'Save'
		end
		expect(page).to have_content("Requirement was successfully created.")
		expect(page).to have_content("new_group_#{@temp}")
		
		click_link "delete_requirement_new_group_#{@temp}"
		
		find('.confirm').click
		expect(page).to have_no_content("new_group_#{@temp}")

	end

	scenario 'requirement editor creates a DMP Template' do #, :js => true do

		logs_in_with "#{REQ_EDITOR_USERNAME}", "#{REQ_EDITOR_PASSWORD}", "#{REQ_EDITOR_INSTITUTION_NAME}"

		expect(page).to have_link('My Dashboard')
		expect(page).to have_link('My Profile')		
		expect(page).to have_link('DMP Templates')		

		expect(page).to have_no_link('Customizations')  
		expect(page).to have_no_link('Institution Profile') 
		expect(page).to have_no_link('DMP Administration')	

		#My Dashboard sections are present
		within('#quick_dashboard') do
			click_link 'My Dashboard'
		end
		expect(page).to have_content(%r{#{"Overview"}}i)
		expect(page).to have_content("DMP Templates")

		
		within('#quick_dashboard') do
			click_link 'DMP Templates'
		end
		within('#dmp_templates') do
  		expect(page).to have_content("Visibility")
		end
		

		#create new DMP template
		click_button 'Create New Template'
		expect(page).to have_content(%r{#{"Create New DMP Template"}}i)
		click_button 'Create New Template'
		
		expect(page).to have_content(%r{#{"DMP TEMPLATE OVERVIEW"}}i)
		#expect(page).to have_field("institution_name", :disabled => true)
		expect(page).to have_content("Test Institution")
		@temp = Time.now.to_s
		fill_in 'requirements_template_name', with: "test-template-1-public_#{@temp}"
		page.choose 'public'
		click_button 'Save and Next >>'
		expect(page).to have_content("DMP Template was successfully created.")

		#delete DMP template just created
		within('#quick_dashboard') do
			click_link 'DMP Templates'
		end
		click_link 'view_all_templates'	
		expect(page).to have_content("test-template-1-public_#{@temp}")
	
	end



	scenario 'requirement editor creates a single requirement' , :js => true do

		logs_in_with "#{REQ_EDITOR_USERNAME}", "#{REQ_EDITOR_PASSWORD}", "#{REQ_EDITOR_INSTITUTION_NAME}"
		within('#quick_dashboard') do
			click_link 'DMP Templates'
		end
		click_link 'Institution only'
		find('#top_level_test_inst_template').hover
		find('.details').click
		expect(page).to have_content "top_level_test_inst_template"
		@temp = Time.now.to_s
		fill_in 'requirement_text_brief', with: "bla_#{@temp}"
		fill_in 'requirement_text_full', with: "bla_question_#{@temp}"
		click_button 'Save'
		expect(page).to have_content("Requirement was successfully created.")
		expect(page).to have_content("bla_#{@temp}")
		#within('#req_bla') do
		click_link "delete_requirement_bla_#{@temp}"
		#end
		find('.confirm').click
		expect(page).to have_no_content("bla_#{@temp}")

	end
	


end
