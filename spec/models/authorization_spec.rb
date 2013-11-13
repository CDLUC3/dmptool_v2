require 'spec_helper'

describe Authorization do

  let(:user) { FactoryGirl.create(:user) }
  let(:role) { FactoryGirl.create(:role) }

  before { @authorization = Authorization.new(role_id: role.id, user_id: user.id) }

  subject { @authorization }

  it { should respond_to(:role_id) }
  it { should respond_to(:user_id) }

  it { should belong_to(:user) }
  it { should belong_to(:role) }

  it { should be_valid }

  describe "when user_id is blank" do
    before { @authorization.user_id = nil }
    it { should_not be_valid }
  end

  describe "when role is blank" do
    before { @authorization.role_id = nil}
    it { should_not be_valid}
  end

end
