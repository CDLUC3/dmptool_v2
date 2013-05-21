require 'spec_helper'

describe Institution do
  before { @institution = Institution.new(full_name: "University of California - Test", nickname: "UCT", desc: "This is the description.") }

  subject { @institution }

  it { should respond_to(:full_name) }
  it { should respond_to(:nickname) }
  it { should respond_to(:desc) }
  it { should respond_to(:contact_info) }
  it { should respond_to(:contact_email) }
  it { should respond_to(:url) }
  it { should respond_to(:url_text) }
  it { should respond_to(:shib_entity_id) }
  it { should respond_to(:shib_domain) }

  it { should be_valid }

  describe "when the full name is blank" do
    before { @institution.full_name = "" }
    it { should_not be_valid }
  end
end
