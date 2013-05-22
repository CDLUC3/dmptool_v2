require 'spec_helper'

describe User do

  before { @user = User.new(institution_id: 1, first_name: "John", last_name: "Doe", email: "JohnDoe@ucop.edu") }

  subject { @user }

  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:email) }
  it { should respond_to(:prefs) }
  it { should respond_to(:token) }
  it { should respond_to(:token_expiration) }

  it { should have_many(:plans).through(:user_plans) }
  it { should belong_to(:institution) }
  it { should have_one(:authentication) }
  it { should have_many(:comments) }

  it { should be_valid }

  describe "when institution id is nil" do
    before { @user.institution_id = nil }
    it { should_not be_valid }
  end

  describe "when institution_id is a string" do
    before { @user.institution_id = "abcd" }
    it { should_not be_valid }
  end

  describe "when first name is blank" do
    before { @user.first_name = "" }
    it { should_not be_valid }
  end

  describe "when last name is blank" do
    before { @user.last_name = "" }
    it { should_not be_valid }
  end

  describe "when email is blank" do
    before { @user.email = "" }
    it { should_not be_valid }
  end

  describe "when email is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_att_foo.org example.user@foo foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should be_invalid
      end
    end
  end

  describe "when email is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when there is a duplicate email address" do
    it "should not be valid" do
      @duplicate_user = @user.dup
      @duplicate_user.save
      @user.should_not be_valid
    end
  end

  describe "when there is a duplicate email address with different case" do
    it "should not be valid" do
      @duplicate_user = @user.dup
      @duplicate_user.email.upcase!
      @duplicate_user.save
      @user.should_not be_valid
    end
  end

  describe "when a user is saved" do
    before { @user.save }

    it "should have preferences" do
      @user.prefs.should_not be_empty
    end
  end

  describe "user associations" do
    let!(:institution) { FactoryGirl.create(:institution) }
    let!(:institution2) { FactoryGirl.create(:institution) }
    before do
      @user.institution_id = institution.id
      @user.save
    end

    it { should belong_to(:institution) }
    it { should_not belong_to(:institution2) }
  end

  describe "user should have access to their plans" do
    let!(:plan) { FactoryGirl.create(:plan, users: [@user]) }
    before { @user.save }

    it "should create the proper relationship on plan creation" do
      @user.plans.count.eql?(1)
      @user.plans.first.eql?(plan)
    end
  end
end
