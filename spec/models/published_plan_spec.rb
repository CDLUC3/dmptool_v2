# require 'spec_helper'

# describe PublishedPlan do

#   let(:plan) { FactoryGirl.create(:plan) }

#   before { @published_plan = PublishedPlan.new(plan_id: 1, file_name: "filename.pdf", visibility: :public) }

#   subject { @published_plan }

#   it { should respond_to(:plan_id) }
#   it { should respond_to(:file_name) }
#   it { should respond_to(:visibility) }

#   it { should belong_to(:plan) }

#   it { should be_valid }

#   describe "when plan_id is blank" do
#     before { @published_plan.plan_id = nil }
#     it { should_not be_valid }
#   end

#   describe "when plan_id is alphanumeric" do
#     before { @published_plan.plan_id = "abcd" }
#     it { should_not be_valid }
#   end

#   describe "when file name is blank" do
#     before { @published_plan.file_name = '' }
#     it { should_not be_valid }
#   end

#   describe "when visibility is blank" do
#     before { @published_plan.visibility = nil }
#     it { should_not be_valid }
#   end

#   describe "when the visibility is set to an invalid value" do
#     it "should be invalid" do
#       invalid_visibilities = %w[this is not a valid value]
#       invalid_visibilities.each do |invalid_visibility|
#         @published_plan.visibility = invalid_visibility
#         @published_plan.should_not be_valid
#       end
#     end
#   end

#   describe "when the visibility is set to a valid value" do
#     it "should be valid" do
#       valid_visibilities = %w[public institutional public_browsable]
#       valid_visibilities.each do |valid_visibility|
#         @published_plan.visibility = valid_visibility
#         @published_plan.should be_valid
#       end
#     end
#   end

# end
