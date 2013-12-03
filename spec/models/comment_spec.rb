# require 'spec_helper'

# describe Comment do

#   let(:plan) { FactoryGirl.create(:plan) }
#   let(:user) { FactoryGirl.create(:user) }

#   before { @comment = Comment.new(user_id: user.id, plan_id: plan.id, value: "Lorem Ipsum", visibility: :owner) }

#   subject { @comment }

#   it { should respond_to(:user_id) }
#   it { should respond_to(:plan_id) }
#   it { should respond_to(:value) }
#   it { should respond_to(:visibility) }

#   it { should belong_to(:plan) }
#   it { should belong_to(:user) }

#   it { should be_valid }

#   describe "when user_id is blank" do
#     before { @comment.user_id = nil }
#     it { should_not be_valid }
#   end

#   describe "when plan_id is blank" do
#     before { @comment.plan_id = nil }
#     it { should_not be_valid }
#   end

#   describe "when value is blank" do
#     before { @comment.value = nil }
#     it { should_not be_valid }
#   end

#   describe "when visibility is blank" do
#     before { @comment.visibility = nil }
#     it { should_not be_valid }
#   end

#   describe "when visibility is set to an invalid value" do
#     it "should be invalid" do
#       invalid_visibilities = %w[these are invalid values]
#       invalid_visibilities.each do |invalid_visibility|
#         @comment.visibility = invalid_visibility
#         @comment.should_not be_valid
#       end
#     end
#   end

#   describe "when visibility is set to a valid value" do
#     it "should be valid" do
#       valid_visibilities = %w[owner reviewer]
#       valid_visibilities.each do |valid_visibility|
#         @comment.visibility = valid_visibility
#         @comment.should be_valid
#       end
#     end
#   end
# end
