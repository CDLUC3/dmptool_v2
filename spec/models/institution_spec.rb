require 'spec_helper'

describe Institution do
  before { @institution = Institution.new(full_name: "University of California - Test", nickname: "UCT", desc: "This is the description.") }

  subject { @institution }

  describe "when the full name is blank" do
    before { @institution.full_name = "" }
    it { should_not be_valid }
  end
end
