# require 'spec_helper'

# describe Enumeration do

#   let(:requirement) { FactoryGirl.create(:requirement) }

#   before { @enumeration = Enumeration.new(requirement_id: requirement.id, value: "Lorem Ipsum") }

#   subject { @enumeration }

#   it { should respond_to(:requirement_id) }
#   it { should respond_to(:value) }

#   it { should belong_to(:requirement)}
  
#   it { should be_valid }

#   describe "when requirement_id is blank" do
#     before { @enumeration.requirement_id = nil }
#     it { should_not be_valid }
#   end
  
#   describe "when requirement_id is a string" do
#     before { @enumeration.requirement_id = "text" }
#     it { should_not be_valid }
#   end
# end  
