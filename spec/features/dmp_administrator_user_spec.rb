require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'dmp admin user' do

	scenario 'dmp admin visits my dashboard page' , :js => true do

		
		logs_in_with "#{DMP_ADMIN_USERNAME}", "#{DMP_ADMIN_PASSWORD}", "#{DMP_ADMIN_INSTITUTION_NAME}"

		expect(page).to have_link('My Dashboard')	
		expect(page).to have_link('DMP Templates')		
		expect(page).to have_link('Customizations') 
		expect(page).to have_link('Institution Profile') 
		expect(page).to have_link('My Profile')	
		expect(page).to have_link('DMP Administration')	


		#MY DASHBOARD TEST

	    #My Dashboard sections are present
	    within('#quick_dashboard') do
	    	click_link 'My Dashboard'
	    end
	    expect(page).to have_content(%r{#{"Overview"}}i)
	    expect(page).to have_content("My DMPs under review")
	    expect(page).to have_content("DMP Templates")
	   

	    #buttons are functioning (create new dmp is not working)
	    click_on "create_new_DMP_template"
	    expect(page).to have_content("Create New DMP")
	    within('#quick_dashboard') do
	    	click_link 'My Dashboard'
	    end
	    
	    click_on "create_new_DMP"
	    #expect(page).to have_content("DMP Template Overview")

	    #links are functioning
	    within('#quick_dashboard') do
	    	click_link 'My Dashboard'
	    end
	    # click_link (%r{#{"Institution-only"}}i) #DMP Templates for my institution only
	    # expect(page).to have_content("Visibility")
	    # expect(page).to have_no_content("Public")

	    within('#quick_dashboard') do
	    	click_link 'My Dashboard'
	    end
	    click_on "public_templates" #Public DMP Templates
	    expect(page).to have_content("Visibility")
	    expect(page).to have_content("Public")

	    within('#quick_dashboard') do
	    	click_link 'My Dashboard'
	    end
	    click_on "Customizations" # Resources Templates
	    expect(page).to have_content(%r{#{"DMP Template Customizations"}}i)
			
		end

	scenario 'dmp admin grants and revokes roles through the DMP Admin page' , :js => true do
		
		logs_in_with "#{DMP_ADMIN_USERNAME}", "#{DMP_ADMIN_PASSWORD}", "#{DMP_ADMIN_INSTITUTION_NAME}"
		click_link 'DMP Administration'

		fill_in 'q', with: 'test_user2'
		click_button "Search"

		click_link('edit_14') # edit roles for user_id 14, test_user2
		
		expect(page).to have_content("test_user2 Current Roles:")

		within '#role_1' do
			check 'role_ids_'
		end
		within '#role_3' do
			check 'role_ids_'
		end	
		click_on "Save Changes"

		expect(page).to have_content("User was successfully updated.")

		fill_in 'q', with: 'test_user2'
		click_button "Search"

		within '#user_14' do
			expect(page).to have_content("DMP Administrator")
			expect(page).to have_content("Template Editor")
		end

		click_link('edit_14') # edit roles for user_id 14, test_user2

		within '#role_1' do
			uncheck 'role_ids_'
		end
		within '#role_3' do
			uncheck 'role_ids_'
		end
		click_on "Save Changes"

		fill_in 'q', with: 'test_user2'
		click_button "Search"

		within '#user_14' do
			expect(page).to have_no_content("DMP Administrator")
			expect(page).to have_no_content("Template Editor")
		end

	end

  scenario 'partners page works', :js => true do
    logs_in_with "#{DMP_ADMIN_USERNAME}", "#{DMP_ADMIN_PASSWORD}", "#{DMP_ADMIN_INSTITUTION_NAME}"
    visit("/partners_list")
    expect(page).to have_content("Shibboleth enabled?")
  end
end

















