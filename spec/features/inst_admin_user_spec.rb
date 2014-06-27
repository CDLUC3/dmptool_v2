require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'inst admin user' do 

	scenario 'institutional administrator visibility' do #, :js => true do

		logs_in_with "#{INST_ADMIN_USERNAME}", "#{INST_ADMIN_PASSWORD}", "#{INST_ADMIN_INSTITUTION_NAME}"

		expect(page).to have_link('My Dashboard')	
		expect(page).to have_link('DMP Templates')		
		#expect(page).to have_link('Customizations') 
		expect(page).to have_link('Institution Profile') 
		expect(page).to have_link('My Profile')	
		
		expect(page).to have_no_link('DMP Administration')	


		
	end

end