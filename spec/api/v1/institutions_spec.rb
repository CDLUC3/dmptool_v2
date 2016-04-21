require_relative '../api_spec_helper.rb'

describe 'Institutions API', :type => :api do 
  before :all do
    @institutions = create_test_institutions
    
    @users = create_test_user_per_role(@institutions[0], get_roles)
  end

  # -------------------------------------------------------------
  it 'should return list of plan counts for each institution' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
    
      # Verify that all of our test institutions are there
      institutions = json(response.body)
      
      i = 0
      ids = @institutions.collect{|i| i.id}
      institutions.each do |institution|
        i = i + 1 if ids.include?(institution[:institution][:id])
      end
      expect(i).to eq(ids.size)
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(['/api/v1/institutions_plans_count'], validations)
    test_authorized(@users, ['/api/v1/institutions_plans_count'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return plan count for a specific institution' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
    
      institutions = json(response.body)
      expect(institutions.size).to be >= 1
      
      #Return the institution id so that we can verify it below
      expect(institutions[:institution][:id]).to eql(@institutions[2].id)
      
      # ** SHOULD ALSO VERIFY PLAN COUNT! **
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(["/api/v1/institutions_plans_count/#{@institutions[2].id}"], validations)
    test_authorized(@users, 
                      ["/api/v1/institutions_plans_count/#{@institutions[2].id}"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return list of administrator counts for each institution' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
    
      # Verify that all of our test institutions are there
      institutions = json(response.body)
      
      i = 0
      ids = @institutions.collect{|i| i.id}
      institutions.each do |institution|
        i = i + 1 if ids.include?(institution[:institution][:id])
      end
      expect(i).to eq(ids.size)
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(['/api/v1/institutions_admins_count'], validations)
    test_authorized(@users, ['/api/v1/institutions_admins_count'], validations)
  end

  # -------------------------------------------------------------
  it 'should return administrator count for a specific institution' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
    
      institutions = json(response.body)
      expect(institutions.size).to be >= 1
      
      #Return the institution id so that we can verify it below
      expect(institutions[:institution][:id]).to eq(@institutions[0].id)
      
      # ** SHOULD ALSO VERIFY ADMIN COUNT! **
      expect(institutions[:institution][:admins]).to eq(1)
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(["/api/v1/institutions_admins_count/#{@institutions[0].id}"], validations)
    test_authorized(@users,
                   ["/api/v1/institutions_admins_count/#{@institutions[0].id}"], validations)
  end

  # -------------------------------------------------------------
  it 'should return list of institutions' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
    
      institutions = json(response.body)

      # Verify that we received a result for each of our test institutions
      i = 0
      ids = @institutions.collect{|inst| inst.id}
      institutions.each do |institution|
        i = i + 1 if ids.include?(institution[:institution][:id])
        
        # Make sure that all of the required values were returned
        expect(institution[:institution][:id]).not_to eq(nil)
        expect(institution[:institution][:full_name]).not_to eq(nil)
      end
      expect(i).to eq(3)
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(['/api/v1/institutions'], validations)
    test_authorized(@users, ['/api/v1/institutions'], validations)
  end

  # -------------------------------------------------------------
  it 'should return a specific institution' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
    
      institutions = json(response.body)
      expect(institutions.size).to eq(1)
      
      # The institution returned should match the one we requested!
      expect(institutions[:institution][:full_name]).to eq(@institutions[1].full_name)
      
      # Make sure that all of the required values were returned
      expect(institutions[:institution][:id]).not_to eq(nil)
      expect(institutions[:institution][:full_name]).not_to eq(nil)
    end
    
    # should work whether authorized or unauthorized
    test_unauthorized(["/api/v1/institutions/#{@institutions[1].id}"], validations)
    test_authorized(@users, ["/api/v1/institutions/#{@institutions[1].id}"], validations)
  end
end