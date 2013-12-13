module Features

	module SessionHelpers
		
		def logs_in_with(username, password, institution)
			logs_out
			click_link 'Log In'
			#puts "institution_id.text = #{page.find_field('institution_id').text}"
			#save_and_open_page
			page.select institution, :from => 'institution_id'
			click_button 'Next'
			fill_in 'username', with: 'test_user2'
			fill_in 'password', with: 'test_user2'
			click_button 'Login'
			expect(page).to have_content 'Welcome!'
		end


		def logs_out
			visit logout_path
		end

		def check_quick_dashboard_generic_visibility
  		expect(page).to have_link('My Dashboard')
  		expect(page).to have_link('My Profile')
			
			expect(page).to have_no_link('DMP Templates')		
			expect(page).to have_no_link('Resources')	
			expect(page).to have_no_link('Institution Profile')	
			expect(page).to have_no_link('DMP Administration')		
		end

		def my_dashboard_page
			click_link 'My Dashboard'
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
			expect(page).to have_content "Test sub-inst01"
			page.select "Test sub-inst01", :from => 'user_institution_id'
			click_button 'Save'
			expect(page).to have_content "Test sub-inst01"
		end
	
	end

end


