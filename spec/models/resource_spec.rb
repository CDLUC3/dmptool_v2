require 'spec_helper'

describe Resource do

  let(:resource_template) { FactoryGirl.create(:resource_template) }

  before { @resource = Resource.new(value: 'actionableurl.com', label: 'Useful URL', resource_type: :example_response,
                                    requirement_id: 1, resource_template_id: resource_template.id) }

  subject { @resource }

  it { should respond_to(:resource_type) }
  it { should respond_to(:value) }
  it { should respond_to(:label) }
  it { should respond_to(:requirement_id) }
  it { should respond_to(:resource_template_id) }

  it { should belong_to(:requirement) }
  it { should belong_to(:resource_template) }

  it { should be_valid }

  describe "when resource_type is blank" do
    before { @resource.resource_type = nil }
    it { should_not be_valid }
  end

  describe "when value is blank" do
    before { @resource.value = nil }
    it { should_not be_valid }
  end

  describe "when label is blank" do
    before { @resource.label = nil }
    it { should_not be_valid }
  end

  describe "when requirement_id is blank" do
    before { @resource.requirement_id = nil }
    it { should_not be_valid }
  end

  describe "when resource_template_id is blank" do
    before { @resource.resource_template_id = nil }
    it { should_not be_valid }
  end

  describe "when a resource_type is an invalid value" do
    it "should be invalid" do
      invalid_resource_types = %w[these are not valid types]
      invalid_resource_types.each do |invalid_resource_type|
        @resource.resource_type = invalid_resource_type
        @resource.should_not be_valid
      end
    end
  end

  describe "when a resource_type is a valid value" do
    it "should be valid" do
      valid_resource_types = %w[actionable_url expository_guidance example_response suggested_response]
      valid_resource_types.each do |valid_resource_type|
        @resource.resource_type = valid_resource_type
        @resource.should be_valid
      end
    end
  end

end
