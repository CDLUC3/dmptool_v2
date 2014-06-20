module ApiHelper
=begin
	include Rack::Test::Methods <co id="ch13_458_1"/>

	def app <co id="ch13_458_2"/>
		Rails.application
	end
=end
end
=begin
RSpec.configure do |c|
	c.include ApiHelper, :type => :api <co id="ch13_458_3"/>
end
=end