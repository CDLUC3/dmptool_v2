require 'spec_helper'

describe Role do

  before { @role = Role.new(name: 'dmp_administrator')}

  subject { @role }

  it { should respond_to(:name) }

  it { should have_many(:authorizations)}
  it { should have_many(:users).through(:authorizations) }

  it { should be_valid }

  describe "when name is blank" do
    before { @role.name = '' }
    it { should_not be_valid }
  end

end
