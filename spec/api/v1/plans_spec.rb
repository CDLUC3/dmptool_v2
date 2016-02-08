require 'spec_helper'
require_relative '../api_spec_helper.rb'

describe 'Plans API', :type => :api do 

  before :all do
    @institutions = create_test_institutions

    #Users from Intition 1
    @users = create_test_user_per_role(@institutions[0], get_roles)
    
    @dmp_admin = @users.select{|u| u.has_role?(Role::DMP_ADMIN)}[0]
    @inst_admin = @users.select{|u| u.has_role?(Role::INSTITUTIONAL_ADMIN)}[0]
    @inst_reviewer = @users.select{|u| u.has_role?(Role::INSTITUTIONAL_REVIEWER)}[0]
    @template_editor = @users.select{|u| u.has_role?(Role::TEMPLATE_EDITOR)}[0]
    @resource_editor = @users.select{|u| u.has_role?(Role::RESOURCE_EDITOR)}[0]

    @inst_users = [@inst_admin, @inst_reviewer, @template_editor, @resource_editor];
    
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
        create_test_plan(@templates[1], 'private', @inst_admin, @resource_editor),
        create_test_plan(@templates[1], 'public', @inst_admin, nil),
        create_test_plan(@templates[0], 'private', @inst_admin, @resource_editor),
        create_test_plan(@templates[1], 'institutional', @inst_admin, @resource_editor),
        create_test_plan(@templates[0], 'unit', @inst_admin, @resource_editor)
    ]

    @template_editor_plans = [
      create_test_plan(@templates[1], 'private', @template_editor, nil),
      create_test_plan(@templates[1], 'institutional', @template_editor, @resource_editor),
      create_test_plan(@templates[0], 'unit', @template_editor, nil)
    ]
    
    @resource_editor_plans = [create_test_plan(@templates[1], 'private', @resource_editor, nil)]
    @resource_editor_plans.concat @inst_admin_plans.select{|p| p.coowners.include?(@resource_editor)}
    @resource_editor_plans.concat @template_editor_plans.select{|p| p.coowners.include?(@resource_editor)}
    
    @template_editor2_plans = [create_test_plan(@templates2[0], 'public', @template_editor2, nil)]
    
    @inaccessible_plans = [
      create_test_plan(@templates2[0], 'private', @template_editor2, nil),
      create_test_plan(@templates2[0], 'institutional', @template_editor2, nil),
      create_test_plan(@templates2[0], 'unit', @template_editor2, nil)
    ]
        
    @unused_templates = [@templates2[1]]
    
    @public_plans = @inst_admin_plans.select{|p| p.visibility === 'public'}
    @public_plans.concat @template_editor2_plans.select{|p| p.visibility === 'public'}
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
      ids = @resource_editor_plans.collect{|p| p.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      i.should eql @resource_editor_plans.size
    end
  
    test_specific_role(@resource_editor, ["/api/v1/plans", "/api/v1/plans_full"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of ALL plans for the dmp_admin' do 
    plans = @resource_editor_plans.collect{|p| p.id}
    plans.concat @template_editor_plans.collect{|p| p.id}
    plans.concat @template_editor2_plans.collect{|p| p.id}
    plans.concat @inst_admin_plans.collect{|p| p.id}
    plans.concat @inaccessible_plans.collect{|p| p.id}
    
    plans = plans.uniq
    
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      json = json(response.body)
      
      i = 0
      json.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if plans.include?(plan[:plan][:id])
      end
      
      i.should eql plans.size
    end
  
    test_specific_role(@dmp_admin, ["/api/v1/plans", "/api/v1/plans_full"], validations)
  end
  
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
    plan_ids = @resource_editor_plans.collect{|p| p.id}
       
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
    plans = @resource_editor_plans.collect{|p| p.id}
    plans.concat @template_editor_plans.collect{|p| p.id}
    plans.concat @template_editor2_plans.collect{|p| p.id}
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

  # -------------------------------------------------------------
  it 'should return a list of plans used for the institutional user' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = @unused_templates.collect{|p| p.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:template][:id])
      end
      
      i.should eql 0
    end
  
    test_authorized(@inst_users, ["/api/v1/plans_templates"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a specific used plan for the institutional user' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      json = json(response.body)
      json.size.should eql 1

      # The plan returned should match the one we requested!
       json[:plan][:id].should be
       json[:plan][:created].should be
       json[:plan][:template][:id].should be
       json[:plan][:template][:name].should be
    end

    @inst_admin_plans.each do |plan|
      test_specific_role(@inst_admin, ["/api/v1/plans_templates/#{plan.id}"], validations)
    end

    @template_editor_plans.each do |plan|
      test_specific_role(@template_editor, ["/api/v1/plans_templates/#{plan.id}"], validations)
    end

    @resource_editor_plans.each do |plan|
      test_specific_role(@resource_editor, ["/api/v1/plans_templates/#{plan.id}"], validations)
    end
  end

  # -------------------------------------------------------------
  it 'should NOT return a list of plans used or a specific plan used for an unauthorized user' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
  
    test_unauthorized(["/api/v1/plans_templates", "/api/v1/plans_templates/#{@resource_editor_plans[1].id}"], validations)
    test_specific_role(@dmp_admin, ["/api/v1/plans_templates", "/api/v1/plans_templates/#{@inst_admin_plans[1].id}"], validations)
  end

# TODO: Need to add tests for the other routes
#       Need to fix issue with dmp_admin return list test  
  
end