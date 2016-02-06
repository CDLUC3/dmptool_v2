require 'spec_helper'
require_relative '../api_spec_helper.rb'

describe 'Plans API', :type => :api do 

  before :all do
    @institutions = create_test_institutions

    #Users from Intition 1
    @users = create_test_user_per_role(@institutions[0], get_roles)
    
    @dmp_admin = @users.select{|u| u.has_role?(Role::DMP_ADMIN)}[0]
    @inst_admin = @users.select{|u| u.has_role?(Role::INSTITUTIONAL_ADMIN)}[0]
    @resource_editor = @users.select{|u| u.has_role?(Role::RESOURCE_EDITOR)}[0]
    
    #User for Institution 2
    @template_editor2 = create(:api_user, institution_id: @institutions[1].id)
    @template_editor2.update_authorizations([Role::TEMPLATE_EDITOR])

    # Templates for both institutions
    @templates = create_test_templates(@institutions[0])
    @templates2 = create_test_templates(@institutions[1])
    
    # Plans
    @inst_admin_plans = [
        create_test_plan(@templates[0], 'institutional', @inst_admin, nil),
        create_test_plan(@templates[0], 'unit', @inst_admin, nil),
        create_test_plan(@templates[0], 'public', @inst_admin, nil),
        create_test_plan(@templates[1], 'private', @inst_admin, @resource_editor)
    ]

    @inst_user_plans = [
      create_test_plan(@templates2[0], 'public', @template_editor2, nil),
      create_test_plan(@templates[1], 'public', @inst_admin, nil),
      create_test_plan(@templates[1], 'private', @resource_editor, nil),
      create_test_plan(@templates[0], 'private', @inst_admin, @resource_editor),
      create_test_plan(@templates[1], 'institutional', @resource_editor, nil),
      create_test_plan(@templates[0], 'unit', @resource_editor, nil),
      create_test_plan(@templates[1], 'institutional', @inst_admin, @resource_editor),
      create_test_plan(@templates[0], 'unit', @inst_admin, @resource_editor)
    ]
    
    @inaccessible_plans = [
      create_test_plan(@templates2[0], 'private', @template_editor2, nil),
      create_test_plan(@templates2[0], 'institutional', @template_editor2, nil),
      create_test_plan(@templates2[0], 'unit', @template_editor2, nil)
    ]
    
    @public_plans = @inst_admin_plans.select{|p| p.visibility === 'public'}
    @public_plans.concat @inst_user_plans.select{|p| p.visibility === 'public'}
  end
  
  # -------------------------------------------------------------
  it 'should return a list of public plans for an unauthorized user' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
      
      plans = json(response.body)

      i = 0
      ids = @public_plans.collect{|p| p.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      i.should eql @public_plans.size
    end
  
    test_unauthorized(["/api/v1/plans", "/api/v1/plans_full"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of plans for the institutional_admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = @inst_admin_plans.collect{|p| p.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      i.should eql @inst_admin_plans.size
    end
  
    test_specific_role(@inst_admin, ["/api/v1/plans", "/api/v1/plans_full"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of plans for the institutional non-admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = @inst_user_plans.collect{|p| p.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      i.should eql @inst_user_plans.size
    end
  
    test_specific_role(@resource_editor, ["/api/v1/plans", "/api/v1/plans_full"], validations)
  end

=begin
  # -------------------------------------------------------------
  it 'should return a list of ALL plans for the dmp_admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = @inst_user_plans.collect{|t| t.id}
      ids.concat @inst_admin_plans.collect{|t| t.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      i.should eql @plans.size
    end
  
    test_specific_role(@dmp_admin, ["/api/v1/plans", "/api/v1/plans_full"], validations)
  end
=end
  
  # -------------------------------------------------------------
  it 'should return a specific plan for the institutional_admin' do 
    plan_ids = @inst_admin_plans.collect{|p| p.id}
    
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)
      plans.size.should eql 1

      # The plan returned should match the one we requested!
      plan_ids.should include plans[:plan][:id]
    
      # Make sure all of the required values are present
      plans[:plan][:id].should be
      plans[:plan][:name].should be
      plans[:plan][:visibility].should be
    end
  
    plan_ids.each do |plan_id|
      test_specific_role(@inst_admin, 
          ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end

  # -------------------------------------------------------------
  it 'should NOT return a specific plan for the institutional_admin' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
  
    @inaccessible_plans.collect{|p| p.id}.each do |plan_id|
      test_specific_role(@inst_admin,
                ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end

  # -------------------------------------------------------------
  it 'should return a specific plan for the institutional non-admin' do 
    plan_ids = @inst_user_plans.collect{|p| p.id}
       
    validations = lambda do |role, response|      
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)
      plans.size.should eql 1

      # The plan returned should match the one we requested!
      plan_ids.should include plans[:plan][:id]
    end
  
    plan_ids.each do |plan_id|
      test_specific_role(@resource_editor, 
          ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end
  
  # -------------------------------------------------------------
  it 'should NOT return a specific plan for the institutional non-admin' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
  
    @inaccessible_plans.collect{|p| p.id}.each do |plan_id|
      test_specific_role(@inst_admin,
                ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end

  # -------------------------------------------------------------
  it 'should return a specific plan for the dmp_admin' do 
    plans = @inst_user_plans.collect{|p| p.id}
    plans.concat @inst_admin_plans.collect{|p| p.id}
    plans.concat @inaccessible_plans.collect{|p| p.id}
    
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      json = json(response.body)
      json.size.should eql 1

      # The plan returned should match the one we requested!
       plans.should include json[:plan][:id]
    end
  
    plans.each do |plan|
      test_specific_role(@dmp_admin,
              ["/api/v1/plans/#{plan}", "/api/v1/plans_full/#{plan}"], validations)
    end
  end

# TODO: Need to add tests for the other routes
#       Need to fix issue with dmp_admin return list test  
  
end