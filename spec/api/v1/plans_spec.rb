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
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
      
      plans = json(response.body)

      i = 0
      ids = @public_plans.collect{|p| p.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      expect(i).to eq(@public_plans.size)
    end
  
    test_unauthorized(["/api/v1/plans", "/api/v1/plans_full"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of plans for the institutional_admin' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = @inst_admin_plans.collect{|p| p.id}

      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      expect(i).to eq(@inst_admin_plans.size)
    end
  
    test_specific_role(@inst_admin, ["/api/v1/plans", "/api/v1/plans_full"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of plans for the institutional non-admin' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = @resource_editor_plans.collect{|p| p.id}

      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      expect(i).to eq(@resource_editor_plans.size)
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
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
  
      json = json(response.body)
      
      i = 0
      json.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if plans.include?(plan[:plan][:id])
      end
      
      expect(i).to eq(plans.size)
    end
  
    test_specific_role(@dmp_admin, ["/api/v1/plans", "/api/v1/plans_full"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a specific plan for the institutional_admin' do 
    plan_ids = @inst_admin_plans.collect{|p| p.id}
    
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
  
      plans = json(response.body)
      expect(plans.size).to eq(1)

      # The plan returned should match the one we requested!
      expect(plan_ids).to include(plans[:plan][:id])
    
      # Make sure all of the required values are present
      expect(plans[:plan][:id]).not_to eq(nil)
      expect(plans[:plan][:name]).not_to eq(nil)
      expect(plans[:plan][:visibility]).not_to eq(nil)
    end
  
    plan_ids.each do |plan_id|
      test_specific_role(@inst_admin, 
          ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end

  # -------------------------------------------------------------
  it 'should NOT return a specific plan for the institutional_admin' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(401)
      expect(response.content_type).to eq(Mime::JSON)
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
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
  
      plans = json(response.body)
      expect(plans.size).to eq(1)

      # The plan returned should match the one we requested!
      expect(plan_ids).to include(plans[:plan][:id])
    end
  
    plan_ids.each do |plan_id|
      test_specific_role(@resource_editor, 
          ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end
  
  # -------------------------------------------------------------
  it 'should NOT return a specific plan for the institutional non-admin' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(401)
      expect(response.content_type).to eq(Mime::JSON)
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
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
    end
    
    test_specific_role(@dmp_admin, ["/api/v1/plans_templates", "/api/v1/plans_templates/#{@inst_admin_plans[1].id}"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of plans owned by the user' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = @inst_admin_plans.collect{|p| p.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      expect(i).to eq(@inst_admin_plans.size)
    end
  
    test_specific_role(@inst_admin, ["/api/v1/plans_owned", "/api/v1/plans_owned_full"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a list of plans and their templates' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
  
      plans = json(response.body)

      expect(plans.size).to be > 0
    end
  
    [@dmp_admin, @inst_admin, @resource_editor].each do |role|
      test_specific_role(role, ["/api/v1/plans_templates"], validations)
    end
  end
end