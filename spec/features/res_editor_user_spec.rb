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


end
