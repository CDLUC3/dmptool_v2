require 'spec_helper'

describe PermissionGroup do

  let(:institution) { FactoryGirl.create(:institution) }

  before { @permission_group = PermissionGroup.new(group: 1, institution_id: institution.id) }

  subject { @permission_group }

  it { should respond_to(:group) }
  it { should respond_to(:institution_id) }

  it { should belong_to(:institution) }

  it { should be_valid }

  describe "when group is blank" do
    before { @permission_group.group = nil }
    it { should_not be_valid }
  end

  describe "when institution_id is blank" do
    before { @permission_group.institution_id = nil }
    it { should_not be_valid }
  end

end
