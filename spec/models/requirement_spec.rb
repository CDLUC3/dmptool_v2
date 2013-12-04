# require 'spec_helper'

# describe Requirement do

#   let(:requirements_template) { FactoryGirl.create(:requirements_template) }

#   before { @requirement = Requirement.new(order: 1, text_brief: "Lorem Ipsum",
#                           text_full: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur non dui id sem hendrerit ullamcorper. Nulla facilisi. Donec mi tellus, molestie ut euismod a, tincidunt at metus. Sed eleifend ullamcorper eros in consequat. Aenean nec odio magna, vitae porta metus.",
#                           requirement_type: :text, obligation: :optional, default: "Lorem Ipsum", requirements_template_id: requirements_template.id ) }

#   subject { @requirement }

#   it { should respond_to(:order)}
#   it { should respond_to(:ancestry)}
#   it { should respond_to(:text_brief)}
#   it { should respond_to(:text_full)}
#   it { should respond_to(:requirement_type)}
#   it { should respond_to(:obligation)}
#   it { should respond_to(:default)}
#   it { should respond_to(:requirements_template_id)}

#   it { should belong_to(:requirements_template)}
#   it { should have_many(:responses)}
#   it { should have_many(:resources)}
#   it { should have_many(:enumerations)}

#   it { should be_valid }

#   describe "when requirements_template_id is blank" do
#     before { @requirement.requirements_template_id = nil }
#     it { should_not be_valid }
#   end

#     describe "when requirements_template_id is a string" do
#     before { @requirement.requirements_template_id = "text" }
#     it { should_not be_valid }
#   end

#   describe "when the Declarative Label(text_brief) is blank" do
#     before { @requirement.text_brief = "" }
#     it { should_not be_valid }
#   end

#   describe "when obligation is invalid value"
#     it "should not be valid" do
#       invalid_obligations =  %w[these are invalid obligation values]
#       invalid_obligations.each do |invalid_obligation|
#        @requirement.obligation = invalid_obligation
#        @requirement.should_not be_valid
#     end
#   end

#   describe "when obligation is a valid value"
#     it "should be valid" do
#       valid_obligations = %w[mandatory mandatory_applicable recommended optional]
#       valid_obligations.each do |valid_obligation|
#         @requirement.obligation = valid_obligation
#         @requirement.should be_valid
#     end
#   end

#   describe "when requirement_type is an invalid value"
#     it "should be not be valid" do
#       invalid_requirement_types = %w[these are invalid invalid requirement types]
#       invalid_requirement_types.each do |invalid_requirement_type|
#         @requirement.requirement_type = invalid_requirement_type
#         @requirement.should_not be_valid
#     end
#   end

#   describe "when requirement_type is a valid value"
#     it "should be valid" do
#       valid_requirement_types = %w[text numeric date enum]
#       valid_requirement_types.each do |valid_requirement_type|
#         @requirement.requirement_type = valid_requirement_type
#         @requirement.should be_valid
#     end
#   end

# end