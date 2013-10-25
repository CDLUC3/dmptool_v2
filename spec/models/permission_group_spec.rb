require 'spec_helper'

describe PermissionGroup do

  let(:institution) { FactoryGirl.create(:institution) }

  before { @permission_group = PermissionGroup.new(group: 1, institution_id: institution.id) }

  subject { @permission_group }

  it { should respond_to(:group) }
  it { should respond_to(:institution_id) }
  it { should belong_to(:authorizations)}
  it { should belong_to(:institutions) }

  it { should be_valid }

end
