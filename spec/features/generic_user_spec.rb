require 'spec_helper'
require 'support/features/credentials'
include Credentials


feature 'generic user' do 

	scenario 'generic user dashboard visibility' do #, :js => true do

		logs_in_with "testsub_01", "testsub_01", "sub test institution 1"

		check_quick_dashboard_generic_visibility
	
		my_dashboard_page
	
		edit_my_profile

		#change_my_institution("Test Institution", 'Test sub-inst01')

	end

	
end

	

