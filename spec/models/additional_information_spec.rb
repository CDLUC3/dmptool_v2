require 'spec_helper'

describe AdditionalInformation do

  let(:requirements_template) { FactoryGirl.create(:requirements_template) }

  before { @additional_information = AdditionalInformation.new(requirements_template_id: requirements_template.id, label: "Lorem Ipsum", url: "myurl.com")}

  subject { @additional_information }

  it { should respond_to(:requirements_template_id) }
  it { should respond_to(:label)}
  it { should respond_to(:url)}

  it { should belong_to(:requirements_template) }

  describe "when requirements_template_id is blank" do
    before { @additional_information.requirements_template_id = nil }
    it { should_not be_valid }
  end

  describe "when requirements_template_id is a string" do
    before { @additional_information.requirements_template_id = "text" }
    it { should_not be_valid }
  end

end
