require 'spec_helper'

require 'omniauth/auth_hash'

describe 'User', :type => :model do 
  before :all do
    @institution = Institution.new(id: 1, full_name: "Test Institution")
    @user = User.new(
      institution: @institution, 
      first_name: "John", 
      last_name: "Doe", 
      email: "John.Doe@ucop.edu",
      prefs: {},
      login_id: "jdoe",
      password: "passWord12",
      password_confirmation: "passWord12"
    ) 
     
    @omniauth_single_vals = OmniAuth::AuthHash.new(
      provider: 'shibboleth', 
      uid: 'jdoe',
      info: {
        name: 'John Doe',
        email: 'john.doe@test.org',
        first_name: 'John',
        last_name: 'Doe'
      }
    )
     
    @omniauth_double_vals = OmniAuth::AuthHash.new(
      provider: 'shibboleth', 
      uid: 'john.doe@test.org,jdoe;12577;,',
      info: {
        name: 'John Doe',
        email: 'john.doe@test.org;jdoe@test.org,John.Doe@test.org;',
        first_name: 'John',
        last_name: 'Doe'
      }
    )
  end

  # -----------------------------------------------------------------
  it 'should respond to expected attributes' do
    expect(@user).to respond_to(:first_name) 
    expect(@user).to respond_to(:last_name) 
    expect(@user).to respond_to(:email) 
    expect(@user).to respond_to(:prefs) 
    expect(@user).to respond_to(:token) 
    expect(@user).to respond_to(:token_expiration) 

    expect(@user.institution).to eq(@institution) 

    expect(@user.errors.size).to eq(0)
    expect(@user.valid?).to eq(true)
  end

  # -----------------------------------------------------------------
  it 'should create a user via OmniAuth' do
    [@omniauth_single_vals, @omniauth_double_vals].each do |vals|
      usr = User.from_omniauth(@omniauth_double_vals, 'test')
    
      usr.institution = @institution
     
      expect(usr.valid?).to eq(true)
    
      # Make sure that the email and login only include one value
      [usr.login_id, usr.email].each do |val|
        expect(val).not_to include(';')
        expect(val).not_to include(',')
      end
    end
  end

#   describe "when institution id is nil" do
#     before do
#       @user.institution_id = nil
#       @duplicate_user = @user.dup
#     end

#     it "should default to 0" do
#       @user.save
#       @user.institution_id.eql?(0)
#     end
#   end

#   describe "when institution_id is a string" do
#     before { @user.institution_id = "abcd" }
#     it { should_not be_valid }
#   end

#   describe "when first name is blank" do
#     before { @user.first_name = "" }
#     it { should_not be_valid }
#   end

#   describe "when last name is blank" do
#     before { @user.last_name = "" }
#     it { should_not be_valid }
#   end

#   describe "when email is blank" do
#     before { @user.email = "" }
#     it { should_not be_valid }
#   end

#   describe "when email is invalid" do
#     it "should be invalid" do
#       addresses = %w[user@foo,com user_att_foo.org example.user@foo foo@bar_baz.com foo@bar+baz.com]
#       addresses.each do |invalid_address|
#         @user.email = invalid_address
#         @user.should be_invalid
#       end
#     end
#   end

#   describe "when email is valid" do
#     it "should be valid" do
#       addresses = %w[user@foo.COM A_US@f.b.org frst.lst@foo.jp a+b@baz.cn]
#       addresses.each do |valid_address|
#         @user.email = valid_address
#         @user.should be_valid
#       end
#     end
#   end

#   describe "when there is a duplicate email address" do
#     it "should not be valid" do
#       @duplicate_user = @user.dup
#       @duplicate_user.save
#       @user.should_not be_valid
#     end
#   end

#   describe "when there is a duplicate email address with different case" do
#     it "should not be valid" do
#       @duplicate_user = @user.dup
#       @duplicate_user.email.upcase!
#       @duplicate_user.save
#       @user.should_not be_valid
#     end
#   end

#   describe "when a user is saved" do
#     before { @user.save }

#     it "should have preferences" do
#       @user.prefs.should_not be_empty
#     end
#   end

#   describe "user associations" do
#     let!(:institution) { FactoryGirl.create(:institution) }
#     let!(:institution2) { FactoryGirl.create(:institution) }
#     before do
#       @user.institution_id = institution.id
#       @user.save
#     end

#     it { should belong_to(:institution) }
#     it { should_not belong_to(:institution2) }
#   end

#   describe "user should have access to their plans" do
#     let!(:plan) { FactoryGirl.create(:plan, users: [@user]) }
#     before { @user.save }

#     it "should create the proper relationship on plan creation" do
#       @user.plans.count.eql?(1)
#       @user.plans.first.eql?(plan)
#     end
#   end
end
