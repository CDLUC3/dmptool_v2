require 'spec_helper'

include Credentials

describe 'plans', :type => :api do

	
	@inst_1 = Institution.create!(full_name: 'inst_1', nickname: 'i_1')

	@rt_1 = RequirementsTemplate.create!(
																institution_id: @inst_1.id, name: 'rt_1', 
																active: 'active', start_date: '2014-04-17 05:07:50',
																visibility: 'public', review_type: 'no_review',
																created_at: '2009-08-04 18:02:26', updated_at: '2009-08-04 18:02:26')


	# @plan_1 = Plan.create!(
	# 									name: 'plan_1', requirements_template_id: @rt_1.id, visibility: 'public', 
	# 									created_at: '2011-08-04 18:02:26', updated_at: '2011-09-21 19:23:00',
	# 									current_plan_state_id: 1) 

	# @plan_2 = Plan.create!(
	# 									name: 'plan_2', requirements_template_id: @rt_1.id, visibility: 'public', 
	# 									created_at: '2013-01-02 19:08:43', updated_at: '2014-04-17 05:07:50', 
	# 									current_plan_state_id: 1) 

	# @plan_3 = Plan.create!(
	# 									name: 'plan_3', requirements_template_id: @rt_1.id, visibility: 'public', 
	# 									created_at: '2010-12-24 19:08:43', updated_at: '2014-04-17 05:07:50', 
	# 									current_plan_state_id: 1) 
	


	it 'returns list of all plans' do 
		get '/api/v1/plans'
		response.status.should eql(200)
		# response.should be_success
	end


	it 'returns plans ordered by creation date' do 
		get '/api/v1/plans?order=date'
		response.status.should eql(200)

		# plans = JSON.parse(response.body, symbolize_names: true)
		# names = plans.collect{ |p| p[:name] }
		# names.should include @plan_1.name
		# names.first.should == @plan_3.name

		# expect(names).to include(@plan_1.name)

		# body["email"].should == @user_attributes[:email]

		

	end


end


