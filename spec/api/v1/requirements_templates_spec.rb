require_relative '../api_spec_helper.rb'

describe 'Templates API', :type => :api do 
  before :all do
    @institutions = create_test_institutions
    
    @users = create_test_user_per_role(@institutions[0], get_roles)

    @dmp_admin = @users.select{|u| u.has_role?(Role::DMP_ADMIN)}[0]
    @inst_users = @users.select{|u| u.id != @dmp_admin.id}
    
    @templates = create_test_templates(@institutions[0])
    @templates2 = create_test_templates(@institutions[1])
  end
  
  # -------------------------------------------------------------
  it 'should return a 401 for requests without authorization' do
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
    
    test_unauthorized(['/api/v1/templates'], validations)
  end

  # -------------------------------------------------------------
  it 'should return a 401 for a non-institutional user' do
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
    
    test_specific_role(@dmp_admin, ['/api/v1/templates'], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of templates for the authorized user' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
      
      templates = json(response.body)

      i = 0
      ids = @templates.collect{|t| t.id}

      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
        
        # Make sure all of the required values are present
        template[:template][:id].should be
        template[:template][:name].should be
        template[:template][:created].should be
      end
      
      i.should eql @templates.size
    end
    
    test_authorized(@inst_users, ['/api/v1/templates'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should NOT return a list of templates that belong to another institution' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
      
      templates = json(response.body)
      
      i = 0

      ids = @templates2.collect{|t| t.id}
      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
      end
      
      i.should eql 0
    end
    
    test_authorized(@inst_users, ['/api/v1/templates'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a specific template for the authorized user' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
      
      templates = json(response.body)
      
      templates.size.should eql 1

      # The institution returned should match the one we requested!
      @templates.collect{|t| t.id}.should include templates[:template][:id]
      
      # Make sure that all of the required values were returned
      templates[:template][:id].should be
      templates[:template][:name].should be
      templates[:template][:created].should be
    end

    @templates.each do |template|
      test_authorized(@inst_users, ["/api/v1/templates/#{template.id}"], validations)
    end
  end
  
  # -------------------------------------------------------------
  it 'should return a 404 error when requesting a specific template that belongs to another institution' do 
    validations = lambda do |role, response|
      response.status.should eql(404)
      response.content_type.should eql(Mime::JSON)
    end
    
    @templates2.each do |template|
      test_authorized(@inst_users, ["/api/v1/templates/#{template.id}"], validations)
    end
  end
end