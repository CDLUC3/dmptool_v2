require 'spec_helper'

describe ResourceTemplate do

  let(:institution) { FactoryGirl.create(:institution) }
  let(:requirements_template) { FactoryGirl.create(:requirements_template) }

  before { @resource_template = ResourceTemplate.new(name: "My Resource Template", requirements_template_id: requirements_template.id, active: false,
                                                     mandatory_review: false, widget_url: "mywidget.com") }

  subject { @resource_template }

  it { should respond_to(:institution_id) }
  it { should respond_to(:requirements_template_id) }
  it { should respond_to(:name) }
  it { should respond_to(:active) }
  it { should respond_to(:mandatory_review) }
  it { should respond_to(:widget_url) }

  it { should belong_to(:institution) }
  it { should have_many(:resources) }

  it { should be_valid }

  describe "when name is blank" do
    before { @resource_template.name = nil }
    it { should_not be_valid }
  end
end
