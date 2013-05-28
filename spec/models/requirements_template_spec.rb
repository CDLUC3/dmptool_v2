require 'spec_helper'

describe RequirementsTemplate do

  let(:institution) { FactoryGirl.create(:institution)}

  before { @requirements_template = RequirementsTemplate.new(institution_id: institution.id, name: 'Requirements Template Name',
  active: false, start_date: Time.now, end_date: Time.now + 2.weeks, visibility: :public, mandatory_review: false) }

  subject { @requirements_template }

  it { should respond_to(:institution_id) }
  it { should respond_to(:name) }
  it { should respond_to(:active) }
  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:visibility) }
  it { should respond_to(:version) }
  it { should respond_to(:parent_id) }
  it { should respond_to(:mandatory_review) }

  it { should belong_to(:institution) }
  it { should have_many(:resource_templates) }
  it { should have_many(:requirements) }

  it { should be_valid }

  describe "when institution_id is blank" do
    before { @requirements_template .institution_id = nil }
    it { should_not be_valid }
  end

  describe "when name is blank" do
    before { @requirements_template .name = nil }
    it { should_not be_valid }
  end

  describe "when visibility is blank" do
    before { @requirements_template .visibility = nil }
    it { should_not be_valid }
  end

  describe "when version is blank" do
    before { @requirements_template .visibility = nil }
    it { should_not be_valid }
  end

  describe "when visibility is an invalid value" do
    it "should not be valid" do
      invalid_visibilities = %w[these are not valid visibility values]
      invalid_visibilities.each do |invalid_visibility|
        @requirements_template .visibility = invalid_visibility
        @requirements_template .should_not be_valid
      end
    end
  end

  describe "when visibility is a valid value" do
    it "should be valid" do
      valid_visibilities = %w[public institutional]
      valid_visibilities.each do |valid_visibility|
        @requirements_template .visibility = valid_visibility
        @requirements_template .should be_valid
      end
    end
  end

end
