require 'spec_helper'
# require 'support/features/credentials'
# require 'support/features/session_helpers'

include Credentials
# include Features::SessionHelpers


describe 'users', :type => :api do 

	setup { @user = User.create! }

	def encode(username, password)
		ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
	end

	it 'authorization denied if not authenticated' do 

		get '/api/v1/users'
		
		response.status.should eql(401)

	end



	it 'return list of all users if authenticated' do 

		# page.driver.browser.basic_authorize "admin", "secret"

		get '/api/v1/users', {}, { 'Authorization' => encode("#{DMP_ADMIN_USERNAME}", "#{DMP_ADMIN_PASSWORD}") }

		response.status.should eql(200)

	end

	

end
