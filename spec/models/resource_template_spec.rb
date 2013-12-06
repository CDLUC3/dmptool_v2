# require 'spec_helper'

# describe ResourceTemplate do

#   let(:institution) { FactoryGirl.create(:institution) }
#   let(:requirements_template) { FactoryGirl.create(:requirements_template) }

#   before { @resource_template = ResourceTemplate.new(name: "My Resource Template", institution_id: institution.id, requirements_template_id: requirements_template.id, active: false,
#                                                      review_type: :no_review, widget_url: "mywidget.com") }

#   subject { @resource_template }

#   it { should respond_to(:institution_id) }
#   it { should respond_to(:requirements_template_id) }
#   it { should respond_to(:name) }
#   it { should respond_to(:active) }
#   it { should respond_to(:review_type) }
#   it { should respond_to(:widget_url) }

#   it { should belong_to(:institution) }
#   it { should have_many(:resources) }

#   it { should be_valid }

#   describe "when name is blank" do
#     before { @resource_template.name = nil }
#     it { should_not be_valid }
#   end

#   describe "when institution id is blank" do
#     before { @resource_template.institution_id = nil }
#     it { should_not be_valid }
#   end

#   describe "when institution id is not an integer" do
#     before { @resource_template.institution_id = "text" }
#     it { should_not be_valid }
#   end

#   describe "when review_type is an invalid value" do
#     it "should not be valid" do
#       invalid_review_types = %w[these are not valid review_type values]
#       invalid_review_types.each do |invalid_review_type|
#         @resource_template.review_type = invalid_review_type
#         @resource_template.should_not be_valid
#       end
#     end
#   end

#   describe "when review_type is a valid value" do
#     it "should be valid" do
#       valid_review_types = %w[no_review informal_review formal_review]
#       valid_review_types.each do |valid_review_type|
#         @resource_template.review_type = valid_review_type
#         @resource_template.should be_valid
#       end
#     end
#   end
# end
