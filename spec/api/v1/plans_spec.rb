require 'spec_helper'
require_relative '../api_spec_helper.rb'

describe 'Plans API', :type => :api do 
  before :each do
    setup_test_data
  end
  
  # Public plans
  # Insititutional plans
  # Private plans (owned or coowned)
  # 
  # Plan states that are visible at the public level:
  # 'New', 'Completed', 'Submitted', 'Approved', 'Reviewed', 'Rejected',
  # 'Revised', 'Inactive', 'Deleted'

  # -------------------------------------------------------------
  it 'should NOT return a list of plans for an unauthorized user' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)      
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
      ids = [@plan_public_1.id, @plan_public_2.id, 
             @plan_institutional_1.id, @plan_institutional_2.id, 
             @plan_private_1.id, @plan_private_3.id]
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      i.should eql 6
    end
  
    test_specific_role(@institutional_admin, ["/api/v1/plans", 
                                              "/api/v1/plans_full"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a list of plans for the institutional non-admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = [@plan_public_1.id, @plan_public_2.id, 
             @plan_institutional_1.id, @plan_institutional_2.id, 
             @plan_private_2.id]
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      i.should eql 5
    end
  
    test_authorized(@users_without_admin_access, ["/api/v1/plans", 
                                                  "/api/v1/plans_full"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of ALL plans for the dmp_admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)

      i = 0
      ids = @plans.collect{|t| t.id}
      plans.each do |plan|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(plan[:plan][:id])
      end
      
      i.should eql @plans.size
    end
  
    test_specific_role(@dmp_admin, ["/api/v1/plans", "/api/v1/plans_full"], validations)
  end

  # -------------------------------------------------------------
  it 'should return a specific plan for the institutional_admin' do 
    @test_plans = [@plan_public_1.id, @plan_public_2.id, 
                   @plan_institutional_1.id, @plan_institutional_2.id,
                   @plan_private_1.id, @plan_private_3.id]
    
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)
      plans.size.should eql 1

      # The plan returned should match the one we requested!
      @test_plans.should include plans[:plan][:id]
    
      # Make sure all of the required values are present
      plans[:plan][:id].should be
      plans[:plan][:name].should be
      plans[:plan][:visibility].should be
    end
  
    @test_plans.each do |plan_id|
      test_specific_role(@institutional_admin, 
          ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end

  # -------------------------------------------------------------
  it 'should NOT return a specific plan for the institutional_admin' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
  
    [@plan_institutional_3.id, @plan_private_2.id].each do |plan_id|
      test_specific_role(@institutional_admin,
                ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end
  
  # -------------------------------------------------------------
  it 'should return a specific plan for the institutional non-admin' do 
    @test_plans = [@plan_public_1.id, @plan_public_2.id, 
                   @plan_institutional_1.id, @plan_institutional_2.id, 
                   @plan_private_2.id]
       
    validations = lambda do |role, response|      
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)
      plans.size.should eql 1

      # The plan returned should match the one we requested!
      @test_plans.should include plans[:plan][:id]
    end
  
    @test_plans.each do |plan_id|
      test_authorized(@users_without_admin_access,
          ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end
  
  # -------------------------------------------------------------
  it 'should NOT return a specific plan for the institutional non-admin' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
  
    [@plan_institutional_3.id, @plan_private_1.id, @plan_private_3.id].each do |plan_id|
      test_authorized(@users_without_admin_access,
              ["/api/v1/plans/#{plan_id}", "/api/v1/plans_full/#{plan_id}"], validations)
    end
  end

  # -------------------------------------------------------------
  it 'should return a specific plan for the dmp_admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)
      plans.size.should eql 1

      # The plan returned should match the one we requested!
       @plans.collect{|t| t.id}.should include plans[:plan][:id]
    end
  
    @plans.each do |plan|
      test_specific_role(@dmp_admin,
              ["/api/v1/plans/#{plan.id}", "/api/v1/plans_full/#{plan.id}"], validations)
    end
  end

  
  

=begin  
  # -------------------------------------------------------------
  it 'make sure institutional admins cannot see plans for another institituon' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
  
    test_specific_role(@institutional_admin, 
                    ["/api/v1/plans/#{@plan_public_1.id}",
                     "/api/v1/plans/#{@plan_institutional_1.id}",
                     "/api/v1/plans/#{@plan_institutional_2.id}",
                     "/api/v1/plans/#{@plan_private_1.id}",
                     "/api/v1/plans/#{@plan_private_2.id}"], validations)
  end
=end
end