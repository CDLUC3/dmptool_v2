module Features

	module SessionHelpers
		
		def logs_in_with(username, password, institution)
			logs_out
			click_link 'Log In'
			page.select institution, :from => 'institution_id'
			click_button 'Next'
			fill_in 'username', with: username
			fill_in 'password', with: password
			click_button 'Login'
			expect(page).to have_content 'Welcome!'
		end


		def logs_out
			visit logout_path
		end

		def check_quick_dashboard_generic_visibility
			within('#quick_dashboard') do
	  		expect(page).to have_link('My Dashboard')
	  		expect(page).to have_link('My Profile')
				
				expect(page).to have_no_link('DMP Templates')		
				expect(page).to have_no_link('Resources')	
				expect(page).to have_no_link('Institution Profile')	
				expect(page).to have_no_link('DMP Administration')	
			end	
		end

		def my_dashboard_page
			within('#quick_dashboard') do
				click_link 'My Dashboard'
			end
			expect(page).to have_content 'My DMPs'
		end

		def edit_my_profile
			click_link 'My Profile'
			click_link 'Personal Information'
			expect(page).to have_content 'Name'
			expect(page).to have_content 'Contact Information'
			expect(page).to have_content 'Test Institution'	
		end

		def change_my_institution(from, to)
			page.select "Test Institution", :from => 'user_institution_id'
			click_button 'Save'
			expect(page).to have_content "Smithsonian Institution"
			page.select "Test Institution", :from => 'user_institution_id'
			click_button 'Save'
			expect(page).to have_content "Test Institution"
		end

		def accept_browser_dialog
		  if page.driver.class == Capybara::Selenium::Driver
  			page.driver.browser.switch_to.alert.accept
			elsif page.driver.class == Capybara::Webkit::Driver
  			sleep 1 # prevent test from failing by waiting for popup
  			page.driver.browser.accept_js_confirms
			else
  			raise "Unsupported driver"
			end
		end


	
	end

end


