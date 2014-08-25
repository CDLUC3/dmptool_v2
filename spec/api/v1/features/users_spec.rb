require 'spec_helper'
require 'support/features/credentials'
require 'support/features/session_helpers'

include Credentials
include Features::SessionHelpers


feature 'users' do 

	# setup {@user = User.create!(login_id: "#{DMP_ADMIN_USERNAME}", email: 'foo@foo.com')}

	# setup {logs_in_with "#{DMP_ADMIN_USERNAME}", "#{DMP_ADMIN_PASSWORD}", "#{DMP_ADMIN_INSTITUTION_NAME}"}

	setup { @user = User.create! }

	scenario 'return list of all users if authenticated' do #, :js => true do

		# logs_in_with "#{DMP_ADMIN_USERNAME}", "#{DMP_ADMIN_PASSWORD}", "#{DMP_ADMIN_INSTITUTION_NAME}"

		# page.driver.browser.authorize "#{DMP_ADMIN_USERNAME}", "#{DMP_ADMIN_PASSWORD}"
		page.driver.browser.basic_authorize "admin", "secret"

		visit '/api/v1/users'#, {}, {'Authorization' => 'Basic YWRtaW4xMjM6YWRtaW4xMjM='}

		expect(page).to have_content("id")
		expect(page).to have_content("first_name")
		expect(page).to have_content("last_name")
		expect(page).to have_content("email")

	end

	scenario 'authorization denied if not authenticated' do #, :js => true do

		visit '/api/v1/users'

		expect(page).not_to have_content("id")
		expect(page).not_to have_content("first_name")

	end

end
