require 'spec_helper'
require_relative '../api_spec_helper.rb'

describe 'Requirements_Templates API', :type => :api do 
  before :all do
    setup_test_data
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

puts "Insitution: #{@institution_2.id}"
puts "User Insitution: #{@institutional_admin.institution.id}"
puts "RT 1: #{@requirements_template_institutional.institution_id}"
puts "RT 2: #{@requirements_template_institutional_2.institution_id}"
puts "RT Unused: #{@requirements_template_institutional_but_unused.institution_id}"
puts templates
      
      i = 0
      ids = @templates_institutional.collect{|t| t.id}
      templates[:templates].each do |template|
        # Make sure we're showing the right templates!
        i = i + 1 if ids.include?(template[:template][:id])
        
        # Make sure all of the required values are present
        template[:template][:id].should be
        template[:template][:name].should be
        template[:template][:created].should be
      end
      
      i.should eql @templates_institutional.size
    end
    
    test_authorized(@users_with_institutional_access, ['/api/v1/templates'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should NOT return a list of templates that belong to another institution' do 
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
        template[:template][:created].should be
      end
      
      i.should eql @templates_public.size
    end
    
    test_unauthorized(['/api/v1/templates'], validations)
    test_authorized(@users, ['/api/v1/templates'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a specific template for the authorized user' do 
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
        template[:template][:created].should be
      end
      
      i.should eql @templates_public.size
    end
    
    test_authorized(@users_with_institutional_access, ['/api/v1/templates'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a 401 error when requesting a specific template that belongs to another institution' do 
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
        template[:template][:created].should be
      end
      
      i.should eql @templates_public.size
    end
    
    test_unauthorized(['/api/v1/templates'], validations)
    test_authorized(@users, ['/api/v1/templates'], validations)
  end
end