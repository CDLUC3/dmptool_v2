require 'spec_helper'

describe SamplePlan do

  let(:requirements_template) { FactoryGirl.create(:requirements_template)}

  before { @sample_plan = SamplePlan.new(requirements_template_id: requirements_template.id, label: "Lorem Ipsum", url: "myurl.com")}

  subject { @sample_plan }

  it { should respond_to(:requirements_template_id) }
  it { should respond_to(:url)}
  it { should respond_to(:label)}

  it { should belong_to(:requirements_template)}

  it { should be_valid }

end
