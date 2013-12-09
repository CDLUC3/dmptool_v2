# require 'spec_helper'

# describe Tag do
  
#   let(:requirements_template) { FactoryGirl.create(:requirements_template)}

#   before { @tag = Tag.new(requirements_template_id: requirements_template.id, tag: "Lorem Ipsum")}

#   subject { @tag }

#   it { should respond_to(:requirements_template_id) }
#   it { should respond_to(:tag)}
  
#   it { should belong_to(:requirements_template)}

#   it { should be_valid }

#   describe "when requirements_template_id is blank" do
#     before { @tag.requirements_template_id = nil }
#     it { should_not be_valid }
#   end
  
#   describe "when requirements_template_id is a string" do
#     before { @tag.requirements_template_id = "text" }
#     it { should_not be_valid }
#   end

# end
