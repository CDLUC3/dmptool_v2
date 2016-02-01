require 'spec_helper'
require_relative '../api_spec_helper.rb'

describe 'Requirements_Templates API', :type => :api do 
  before :each do
    setup_test_data
  end
  
  # -------------------------------------------------------------
  it 'should return a list of publicly available templates for all users' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
      
      templates = json(response.body)
      
      i = 0
      ids = @templates_public.collect{|t| t.id}
      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
        
        # Make sure all of the required values are present
        template[:template][:id].should be
        template[:template][:name].should be
        template[:template][:visibility].should be
        template[:template][:created].should be
      end
      
      i.should eql @templates_public.size
    end
    
    test_unauthorized(['/api/v1/templates'], validations)
    test_authorized(@users, ['/api/v1/templates'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should NOT return a list of institutional templates for unauthorized users' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
      
      templates = json(response.body)
      
      i = 0
      ids = @templates_institutional.collect{|t| t.id}
      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
      end
      
      i.should eql 0
    end
    
    test_unauthorized(['/api/v1/templates'], validations)
    test_specific_role(@resource_editor2, ['/api/v1/templates'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a list of institutional templates for authorized users' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
      
      templates = json(response.body)
      
      i = 0
      ids = @templates_institutional.collect{|t| t.id}
      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
        
        # Make sure all of the required values are present
        template[:template][:id].should be
        template[:template][:name].should be
        template[:template][:visibility].should be
        template[:template][:created].should be
      end
      
      i.should eql @templates_institutional.size
    end
    
    test_authorized(@users_with_institutional_access, ['/api/v1/templates'], validations)
    test_specific_role(@dmp_admin, ['/api/v1/templates'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a specific publicly available template for all users' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
  
      templates = json(response.body)
      templates.size.should eql 1

      # The template returned should match the one we requested!
      @requirements_template_public.id.should eql templates[:template][:id]
    
      # Make sure all of the required values are present
      templates[:template][:id].should be
      templates[:template][:name].should be
      template[:template][:visibility].should be
      templates[:template][:created].should be
    end
  
    test_authorized(@users, ["/api/v1/templates/#{@requirements_template_public.id}",
                             "/api/v1/templates/#{@requirements_template_public.id}"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should NOT return a specific institutional template for unauthorized users' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
    
    test_unauthorized(["/api/v1/templates/#{@requirements_template_institutional.id}"], validations)
    test_specific_role(@resource_editor2, 
                      ["/api/v1/templates/#{@requirements_template_institutional.id}"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a specific institutional template for authorized users' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
      
      templates = json(response.body)
      templates.size.should eql 1

      # The template returned should match the one we requested!
      @requirements_template_institutional.id.should eql templates[:template][:id]
    
      # Make sure all of the required values are present
      templates[:template][:id].should be
      templates[:template][:name].should be
      template[:template][:visibility].should be
      templates[:template][:created].should be
    end
    
    test_authorized(@users_with_institutional_access, 
                    ["/api/v1/templates/#{@requirements_template_institutional.id}"], validations)
    test_specific_role(@dmp_admin, 
                      ["/api/v1/templates/#{@requirements_template_institutional.id}"], validations)
  end
end