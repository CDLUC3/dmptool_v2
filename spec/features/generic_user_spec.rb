require 'spec_helper'

feature 'generic user' do 

	
	let(:test_institution) {FactoryGirl.create(:institution, full_name: "Test Institution") }
	let(:test_institution_child) {FactoryGirl.create(:institution, full_name: "Test sub-inst01", ancestry: test_institution.id) }
	
	#create method gives validation error mail exists
	let(:generic_user) { FactoryGirl.build(:user, first_name: "test_user2", email: "test_user2@gmail.com") }

	
	

	after { @authentication = Authentication.new(user_id: generic_user.id, provider: :ldap, user_id: "test_user2@gmail.com") }


	scenario 'scenarios' do

		logs_in_with 'test_user2', 'test_user2', test_institution.full_name

		check_quick_dashboard_generic_visibility
	
		my_dashboard_page
	
		edit_my_profile

#TO BE COMPLETED
		#change_my_institution(test_institution, test_institution_child)
			
	end

	
end

