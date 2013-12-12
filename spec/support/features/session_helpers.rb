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
  		expect(page).to have_link('My Dashboard')
  		expect(page).to have_link('My DMPs')
  		expect(page).to have_link('Create New DMP')
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

		# def change_my_institution(from, to)
		# 	page.select "#{to.full_name}", :from => 'user_institution_id'
		# 	click_button 'Save'
		# 	expect(page).to have_content "#{to.full_name}"
		# 	page.select "#{from.full_name}", :from => 'user_institution_id'
		# 	click_button 'Save'
		# 	expect(page).to have_content "#{from.full_name}"
		# 	#expect {post.publish!}.to change {post.published_on}.from(nil).to(Date.today)
		# end
	
	end

end


