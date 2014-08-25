module ApiHelper

	include Rack::Test::Methods 

	def app 
		Rails.application
	end

end
=begin
RSpec.configure do |c|
	c.include ApiHelper, :type => :api <co id="ch13_458_3"/>
end
=end

RSpec.configure do |config|
  config.include ApiHelper, :type=>:api #apply to all spec for apis folder
end