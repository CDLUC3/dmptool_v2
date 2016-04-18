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
      expect(response.status).to eq(401)
      expect(response.content_type).to eq(Mime::JSON)
    end
    
    test_unauthorized(['/api/v1/templates_for_institution'], validations)
  end

  # -------------------------------------------------------------
  it 'should return all templates for the dmp_admin' do
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
      
      templates = json(response.body)
      
      i = 0
      ids = @templates.collect{|t| t.id}

      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
      end
      
      expect(i).to eq(@templates.size)
    end
    
    test_specific_role(@dmp_admin, ['/api/v1/templates_for_institution'], validations)
  end

  # -------------------------------------------------------------
  it 'should return a list of templates for the authorized user' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
      
      templates = json(response.body)

      i = 0
      ids = @templates.collect{|t| t.id}

      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
        
        # Make sure all of the required values are present
        expect(template[:template][:id]).not_to eq(nil)
        expect(template[:template][:name]).not_to eq(nil)
        expect(template[:template][:created]).not_to eq(nil)
      end
      
      expect(i).to eq(@templates.size)
    end
    
    test_authorized(@inst_users, ['/api/v1/templates_for_institution'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should NOT return a list of templates that belong to another institution' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
      
      templates = json(response.body)
      
      i = 0

      ids = @templates2.collect{|t| t.id}
      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
      end
      
      expect(i).to eq(0)
    end
    
    test_authorized(@inst_users, ['/api/v1/templates_for_institution'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a specific template for the authorized user' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::JSON)
      
      templates = json(response.body)
      
      expect(templates.size).to eq(1)

      # The institution returned should match the one we requested!
      expect(@templates.collect{|t| t.id}).to include(templates[:template][:id])
      
      # Make sure that all of the required values were returned
      expect(templates[:template][:id]).not_to eq(nil)
      expect(templates[:template][:name]).not_to eq(nil)
      expect(templates[:template][:created]).not_to eq(nil)
    end

    @templates.each do |template|
      test_authorized(@inst_users, ["/api/v1/templates_for_institution/#{template.id}"], validations)
    end
  end
  
  # -------------------------------------------------------------
  it 'should return a 404 error when requesting a specific template that belongs to another institution' do 
    validations = lambda do |role, response|
      expect(response.status).to eq(404)
      expect(response.content_type).to eq(Mime::JSON)
    end
    
    @templates2.each do |template|
      test_authorized(@inst_users, ["/api/v1/templates_for_institution/#{template.id}"], validations)
    end
  end
end