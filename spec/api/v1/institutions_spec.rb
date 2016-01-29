require 'spec_helper'
require_relative '../api_spec_helper.rb'

describe 'Institutions API', :type => :api do 
  before :each do
    setup_test_data
  end

  # -------------------------------------------------------------
  it 'should return list of plan counts for each institution' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      # Verify that all of our test institutions are there
      institutions = json(response.body)
      
      i = 0
      ids = @institutions.collect{|i| i.id}
      institutions.each do |institution|
        i = i + 1 if ids.include?(institution[:institution][:id])
      end
      i.should eql(ids.size)
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(['/api/v1/institutions_plans_count'], validations)
    test_authorized(@users, ['/api/v1/institutions_plans_count'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return plan count for a specific institution' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      institutions = json(response.body)
      institutions.size.should be >= 1
      
      #Return the institution id so that we can verify it below
      institutions[:institution][:id].should eql @institution_3.id
      
      # ** SHOULD ALSO VERIFY PLAN COUNT! **
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(["/api/v1/institutions_plans_count/#{@institution_3.id}"], validations)
    test_authorized(@users, 
                      ["/api/v1/institutions_plans_count/#{@institution_3.id}"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return list of administrator counts for each institution' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      # Verify that all of our test institutions are there
      institutions = json(response.body)
      
      i = 0
      ids = @institutions.collect{|i| i.id}
      institutions.each do |institution|
        i = i + 1 if ids.include?(institution[:institution][:id])
      end
      i.should eql(ids.size)
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(['/api/v1/institutions_admins_count'], validations)
    test_authorized(@users, ['/api/v1/institutions_admins_count'], validations)
  end

  # -------------------------------------------------------------
  it 'should return administrator count for a specific institution' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      institutions = json(response.body)
      institutions.size.should be >= 1
      
      #Return the institution id so that we can verify it below
      institutions[:institution][:id].should eql @institution_2.id
      
      # ** SHOULD ALSO VERIFY ADMIN COUNT! **
      institutions[:institution][:admins].should eql 1
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(["/api/v1/institutions_admins_count/#{@institution_2.id}"], validations)
    test_authorized(@users,
                   ["/api/v1/institutions_admins_count/#{@institution_2.id}"], validations)
  end

  # -------------------------------------------------------------
  it 'should return list of institutions' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      institutions = json(response.body)

      # Verify that we received a result for each of our test institutions
      i = 0
      ids = @institutions.collect{|inst| inst.id}
      institutions.each do |institution|
        i = i + 1 if ids.include?(institution[:institution][:id])
        
        # Make sure that all of the required values were returned
        institution[:institution][:id].should be
        institution[:institution][:full_name].should be
      end
      i.should eql 3
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(['/api/v1/institutions'], validations)
    test_authorized(@users, ['/api/v1/institutions'], validations)
  end

  # -------------------------------------------------------------
  it 'should return a specific institution' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      institutions = json(response.body)
      institutions.size.should eql 1
      
      # The institution returned should match the one we requested!
      institutions[:institution][:full_name].should eql @institution_2.full_name
      
      # Make sure that all of the required values were returned
      institutions[:institution][:id].should be
      institutions[:institution][:full_name].should be
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(["/api/v1/institutions/#{@institution_2.id}"], validations)
    test_authorized(@users, ["/api/v1/institutions/#{@institution_2.id}"], validations)
  end
end