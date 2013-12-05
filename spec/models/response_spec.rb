# require 'spec_helper'

# describe Response do

#   let(:plan) { FactoryGirl.create(:plan) }
#   let(:requirement) { FactoryGirl.create(:requirement) }

#   before { @response = Response.new(plan_id: plan.id, requirement_id: requirement.id, value: "This is the response.") }

#   subject { @response }

#   it { should respond_to(:plan_id) }
#   it { should respond_to(:requirement_id) }
#   it { should respond_to(:label_id) }
#   it { should respond_to(:value) }

#   it { should belong_to(:plan) }
#   it { should belong_to(:requirement) }
#   it { should belong_to(:label) }

#   it { should be_valid }

#   describe "when plan_id is blank" do
#     before { @response.plan_id = nil }
#     it { should_not be_valid }
#   end

#   describe "when requirement_id is blank" do
#     before { @response.requirement_id = nil }
#     it { should_not be_valid }
#   end

#   describe "when value is blank" do
#     before { @response.value = nil }
#     it { should_not be_valid }
#   end

# end
