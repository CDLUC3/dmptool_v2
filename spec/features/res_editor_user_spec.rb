require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'res editor user' do 

	scenario 'resources editor dashboard visibility' do

		logs_in_with "#{RES_EDITOR_USERNAME}", "#{RES_EDITOR_PASSWORD}", "#{RES_EDITOR_INSTITUTION_NAME}"

		expect(page).to have_link('My Dashboard')
		expect(page).to have_link('My Profile')				
		expect(page).to have_no_link('Institution Profile') 
		expect(page).to have_no_link('DMP Administration')	
		
	end

	# scenario 'resources editor grants and revokes a role' , :js => true do	

	# 	logs_in_with "#{RES_EDITOR_USERNAME}", "#{RES_EDITOR_PASSWORD}", "#{RES_EDITOR_INSTITUTION_NAME}"

	# 	within('#quick_dashboard') do
	# 		click_link 'Resources'
	# 	end

	# 	if page.has_content? "test_user2" 
	# 		click_link 'remove_27'
	# 		find('.confirm').click
	# 	end
	# 	if page.has_content? "test_user2"
	# 		click_link 'remove_27'
	# 		expect(page).to have_no_content("test_user2")
	# 	end

	# 	click_link 'Add New Editor'
	# 	expect(page).to have_content(%r{#{"Grant New Role"}}i)
	# 	fill_in 'email', with: "test_user3@gmail.com"
	# 	click_button 'Submit'
	# 	expect(page).to have_content("You cannot grant this role to users outside your institution")
	# 	click_button 'close'
	# 	visit(current_path)

	# 	click_link 'Add New Editor'
	# 	expect(page).to have_content(%r{#{"Grant New Role"}}i)
	# 	fill_in 'email', with: "test_user99@gmail.com"
	# 	click_button 'Submit'
	# 	expect(page).to have_content("Could not find Users with the following email: test_user99@gmail.com.")
	# 	click_button 'close'
	# 	visit(current_path)

	# 	click_link 'Add New Editor'
	# 	expect(page).to have_content(%r{#{"Grant New Role"}}i)
	# 	fill_in 'email', with: "test_user2@gmail.com"
	# 	click_button 'Submit'
	# 	expect(page).to have_content("Role granted to the following user: test_user2@gmail.com")
	# 	click_button 'close'
	# 	visit(current_path)

	# 	#revoke role just granted
	# 	click_link 'remove_27'
	# 	find('.confirm').click
	# 	if page.has_content? "test_user2"
	# 		click_link 'remove_27'
	# 	end
	# 	expect(page).to have_no_content("test_user2")

		
	# end

end
