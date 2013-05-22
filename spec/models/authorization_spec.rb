require 'spec_helper'

describe Authorization do

  let(:user) { FactoryGirl.create(:user) }

  before { @authorization = Authorization.new(role: :dmp_administrator, group: 1, user_id: user.id) }

  subject { @authorization }

  it { should respond_to(:role) }
  it { should respond_to(:group) }
  it { should respond_to(:user_id) }

  it { should belong_to(:user) }

  it { should be_valid }

  describe "when group is blank" do
    before { @authorization.group = nil }
    it { should_not be_valid }
  end

  describe "when user_id is blank" do
    before { @authorization.user_id = nil }
    it { should_not be_valid }
  end

  describe "when role is blank" do
    before { @authorization.role = nil}
    it { should_not be_valid}
  end

  describe "when role is an invalid value" do
    it "should be invalid" do
      invalid_roles = %w[these are invalid roles]
      invalid_roles.each do |invalid_role|
        @authorization.role = invalid_role
        @authorization.should_not be_valid
      end
    end
  end

  describe "when role is an valid value" do
    it "should be valid" do
      valid_roles = %w[dmp_owner dmp_co_owner requirements_editor resources_editor institutional_reviewer institutional_administrator dmp_administrator]
      valid_roles.each do |valid_role|
        @authorization.role = valid_role
        @authorization.should be_valid
      end
    end
  end

end
