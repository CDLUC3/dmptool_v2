# require 'spec_helper'

# describe Authentication do

#   let(:user) { FactoryGirl.create(:user) }

#   before { @authentication = Authentication.new(user_id: user.id, provider: :shibboleth, uid: user.email) }

#   subject { @authentication }

#   it { should respond_to(:user_id) }
#   it { should respond_to(:provider) }
#   it { should respond_to(:uid) }

#   it { should belong_to(:user) }

#   it { should be_valid }

#   describe "when the user_id is blank" do
#     before { @authentication.user_id = nil }
#     it { should_not be_valid }
#   end

#   describe "when the provider is blank" do
#     before { @authentication.provider = nil }
#     it { should_not be_valid }
#   end

#   describe "when the uid is blank" do
#     before { @authentication.uid = nil }
#     it { should_not be_valid }
#   end

#   describe "when the provider is an invalid value" do
#     it "should not be valid" do
#       invalid_providers = %w[these are not valid providers]
#       invalid_providers.each do |invalid_provider|
#         @authentication.provider = invalid_provider
#         @authentication.should_not be_valid
#       end
#     end
#   end

#   describe "when the provider is an valid value" do
#     it "should be valid" do
#       valid_providers = %w[shibboleth ldap]
#       valid_providers.each do |valid_provider|
#         @authentication.provider = valid_provider
#         @authentication.should be_valid
#       end
#     end
#   end

# end
