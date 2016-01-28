require 'spec_helper'
require_relative '../api_spec_helper.rb'

describe 'plans', :type => :api do 
  before :each do
    setup_test_data
  end
  
  # -------------------------------------------------------------
  it 'should be unable to get list of plans or a specific plan if unauthorized' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
    end
    
    test_unauthorized(['/api/v1/plans', 
                       "/api/v1/plans/#{@plan_public_1.id}",
                       "/api/v1/plans/#{@plan_institutional_1.id}", 
                       "/api/v1/plans/#{@plan_private_1.id}"], validations)
  end
  
  # -------------------------------------------------------------
  it 'return list of plans' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      plans = json(response.body)
      plans.size.should be > 1
      
      i, ids = 0, []
      
      if role === 'dmp_admin'
        # DMP_ADMIN - Should have gotten back ALL of our plans
        ids = @plans.collect{|u| u.id}
                
      elsif role === 'institutional_admin'
        # INSTITUTIONAL_ADMIN - Should have gotten back only plans for the institution
        ids = @institutional_admin.institution.plans.collect{|p| p.id}

      else
        # Not a valid admin role!
        '?_admin'.should eql(role)
      end

      plans.each do |plan|
        # Make sure we're showing the right plans!
        i = i + 1 if ids.include?(plan[:plan][:id])
        
        # Make sure all of the required values are present
        plan[:plan][:id].should be
        plan[:plan][:name].should be
        plan[:plan][:visibility].should be
      end
      
      i.should eql(ids.size)
    end
    
    test_authorized(['/api/v1/plans'], validations)
  end

  # -------------------------------------------------------------
  it 'return a specific plan' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      plans = json(response.body)
      plans.size.should eql 1

      # The plan returned should match the one we requested!
      [@plan_public_2.id, @plan_institutional_3.id].should include plans[:plan][:id]
    
      # Make sure all of the required values are present
      plans[:plan][:id].should be
      plans[:plan][:name].should be
    end
  
    test_authorized(["/api/v1/plans/#{@plan_public_2.id}",
                     "/api/v1/plans/#{@plan_institutional_3.id}"], validations)
  end
  
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
end