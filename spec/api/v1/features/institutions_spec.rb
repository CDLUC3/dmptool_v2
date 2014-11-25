require 'spec_helper'


feature 'institutions' do 

	scenario 'return list of all institutions' do #, :js => true do

		visit '/api/v1/institutions'

		expect(page).to have_content("id")
		expect(page).to have_content("full_name")
		expect(page).to have_content("contact_email")

	end

end
