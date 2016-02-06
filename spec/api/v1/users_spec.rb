require_relative '../api_spec_helper.rb'

describe 'Users API', :type => :api do 

  before :all do
    @institutions = create_test_institutions
    
    @users = create_test_user_per_role(@institutions[0], get_roles)
    @user2 = create(:api_user, institution_id: @institutions[1].id)
    
    @users_with_admin_access = @users.select{|u| u.has_role?(Role::DMP_ADMIN) or
                                                 u.has_role?(Role::INSTITUTIONAL_ADMIN)}

    @users_without_admin_access = (@users - @users_with_admin_access)
    
    @dmp_admin = @users.select{|u| u.has_role?(Role::DMP_ADMIN)}[0]
    @inst_admin = @users.select{|u| u.has_role?(Role::INSTITUTIONAL_ADMIN)}[0]
  end

  # -------------------------------------------------------------
  it 'should not return a list of users or a specific user if user is not an authorized admin' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
    end
    
    test_unauthorized(['/api/v1/users', "/api/v1/users/#{@users[0].id}"], validations)
    
    test_authorized(@users_without_admin_access, 
                      ['/api/v1/users', "/api/v1/users/#{@users[0].id}"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return list of users if current user is an admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      users = json(response.body)
      users.size.should be > 1
      
      i, ids = 0, []
      
      if @dmp_admin.login_id === role
        # DMP_ADMIN - Should have gotten back ALL of our test users
        ids = @users.collect{|u| u.id}
        ids << @user2.id

      elsif @inst_admin.login_id === role
        # INSTITUTIONAL_ADMIN - Should have gotten back only users for their institution except DMP_ADMINs
        ids = (@users).collect{|u| u.id}
        
      else
        # Not a valid admin role so force a failure!
        '?_admin'.should eql(role)
      end
      
      users.each do |user|
        i = i + 1 if ids.include?(user[:user][:id])
        
        # Make sure all of the required values are present
        user[:user][:id].should be
        user[:user][:email].should be
        user[:user][:first_name].should be
        user[:user][:last_name].should be
      
        # Make sure that any values that should NOT be there are missing
        user[:user][:password].should be_nil
        user[:user][:login_id].should be_nil
      end
      
      i.should eql(ids.size)
    end

    test_authorized(@users_with_admin_access, ['/api/v1/users'], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a ANY specific user if current user is a dmp admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      users = json(response.body)
      users.size.should eql 1

      # The user returned should match the one we requested!
      emails = @users.collect{|u| u.email}
      emails << @user2.email
      emails.should include users[:user][:email]
      
      # Make sure all of the required values are present
      users[:user][:email].should be
      users[:user][:first_name].should be
      users[:user][:last_name].should be
      
      # Make sure that any values that should NOT be there are missing
      users[:user][:id].should be_nil
      users[:user][:password].should be_nil
      users[:user][:login_id].should be_nil
    end
    
    @users.each do |user|
      test_specific_role(@dmp_admin, ["/api/v1/users/#{user.id}"], validations)
    end
    
    test_specific_role(@dmp_admin, ["/api/v1/users/#{@user2.id}"], validations)
  end
  
  # -------------------------------------------------------------
  it 'should return a specific user for the institution if current user is a institutional admin' do 
    validations = lambda do |role, response|
      response.status.should eql(200)
      response.content_type.should eql(Mime::JSON)
    
      users = json(response.body)
      users.size.should eql 1
      
      # The user returned should match the one we requested!
      emails = @users.collect{|u| u.email}
      emails.should include users[:user][:email]
      
      # Make sure all of the required values are present
      users[:user][:email].should be
      users[:user][:first_name].should be
      users[:user][:last_name].should be
      
      # Make sure that any values that should NOT be there are missing
      users[:user][:id].should be_nil
      users[:user][:password].should be_nil
      users[:user][:login_id].should be_nil
    end
    
    @users.each do |user|
      test_specific_role(@inst_admin, ["/api/v1/users/#{user.id}"], validations)
    end
  end
  
  # -------------------------------------------------------------
  it 'should not return a specific user if current user is from another institution' do 
    validations = lambda do |role, response|
      response.status.should eql(401)
      response.content_type.should eql(Mime::JSON)
    end
    
    test_specific_role(@inst_admin, ["/api/v1/users/#{@user2.id}"], validations)
  end
end