RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

# -------------------------------------------------------------
def encode(token)
  ActionController::HttpAuthentication::Token.encode_credentials(token)
end

# -----------------------------------------------------------------------------
def json(body)
  JSON.parse(body, symbolize_names: true)
end

# -----------------------------------------------------------------------------
def test_specific_role(user, targets, validations)
  targets.each do |target|
    # Run tests for the specified role
    get target, {}, { 'Accept' => 'application/json',
                      'Authorization' => encode(user.auth_token) }

    validations.call(user.login_id, response)
  end
end

# -----------------------------------------------------------------------------
def test_unauthorized(targets, validations)
  targets.each do |target|
    # Run test when no authorization is provided
    get target
    validations.call(nil, response)
  
    # Run tests for each of the roles that should NOT have access
    @users_without_api_access.each do |user|
      get target, {}, { 'Accept' => 'application/json',
                        'Authorization' => encode(user.auth_token) }
                      
      validations.call(user.login_id, response)
    end
  end
end

# -----------------------------------------------------------------------------
def test_authorized(targets, validations)
  targets.each do |target|
    # Run tests for each of the roles that should have access
    @users_with_api_access.each do |user|
      get target, {}, { 'Accept' => 'application/json',
                        'Authorization' => encode(user.auth_token) }
                      
      validations.call(user.login_id, response)
    end
  end
end

# -----------------------------------------------------------------------------
def setup_test_data
  # Institutions
  @institution_1 = create(:institution_1)
  @institution_2 = create(:institution_2)
  @institution_3 = create(:institution_3)
  
  @institutions = [@institution_1, @institution_2, @institution_3]
  
  # Users and Roles
  @dmp_admin = create(:dmp_admin, institution_id: @institution_1.id)
  @dmp_admin.update_authorizations([Role::DMP_ADMIN])
  @institutional_admin = create(:institutional_admin, institution_id: @institution_2.id)
  @institutional_admin.update_authorizations([Role::INSTITUTIONAL_ADMIN])
  
  @institutional_reviewer = create(:institutional_reviewer, institution_id: @institution_2.id)
  @institutional_reviewer.update_authorizations([Role::INSTITUTIONAL_REVIEWER])
  @template_editor = create(:template_editor, institution_id: @institution_2.id)
  @template_editor.update_authorizations([Role::TEMPLATE_EDITOR])
  @resource_editor = create(:resource_editor, institution_id: @institution_3.id)
  @resource_editor.update_authorizations([Role::RESOURCE_EDITOR])
  
  @users = [@dmp_admin, @institutional_admin, @institutional_reviewer, @template_editor, @resource_editor]
  
  @users_with_api_access = [@dmp_admin, @institutional_admin]
  
  @users_without_api_access = [@institutional_reviewer, @template_editor, @resource_editor]
  
  
  @requirements_template_1 = create(:requirements_template_1, institution_id: @institution_1.id)
  @requirements_template_2 = create(:requirements_template_2, institution_id: @institution_2.id)
  @templates = [@requirements_template_1, @requirements_template_2]
  
  original_plan = Plan.first
  @plan_public_1 = create(:plan_public_1, requirements_template_id: @requirements_template_1.id, original_plan_id: original_plan.id)
  @plan_public_2 = create(:plan_public_2, requirements_template_id: @requirements_template_2.id, original_plan_id: original_plan.id)
  
  @plan_institutional_1 = create(:plan_institutional_1, requirements_template_id: @requirements_template_1.id, original_plan_id: original_plan.id)
  @plan_institutional_2 = create(:plan_institutional_2, requirements_template_id: @requirements_template_1.id, original_plan_id: original_plan.id)
  @plan_institutional_3 = create(:plan_institutional_3, requirements_template_id: @requirements_template_2.id, original_plan_id: original_plan.id)
  
  @plan_private_1 = create(:plan_private_1, requirements_template_id: @requirements_template_1.id, original_plan_id: original_plan.id)
  @plan_private_2 = create(:plan_private_2, requirements_template_id: @requirements_template_2.id, original_plan_id: original_plan.id)
  
  @plans = [@plan_public_1, @plan_public_2, 
            @plan_institutional_1, @plan_institutional_2, @plan_institutional_3,
            @plan_private_1, @plan_private_2]
  
  @plans_public = [@plan_public_1, @plan_public_2]
  @plans_institutional = [@plan_institutional_1, @plan_institutional_2, @plan_institutional_3]
  @plans_private = [@plan_private_1, @plan_private_2]
end

# -----------------------------------------------------------------------------
# Override the real email mechanism to prevent this test from sending out 
# emails when we create our test user
# -----------------------------------------------------------------------------
class UsersMailer < ActionMailer::Base
  def notification(email_address, subject, message_template, locals)
    true
  end
end


FactoryGirl.define do
  # Institutions
  # -------------------------------------------
  factory :institution_1, class: Institution do
    full_name 'Test Institution 1'
    contact_email 'tst@ucop.edu'
  end
  factory :institution_2, class: Institution do
    full_name 'Test Institution 2'
    contact_email 'tst2@ucop.edu'
  end
  factory :institution_3, class: Institution do
    full_name 'Test Institution 3'
    contact_email 'tst3@ucop.edu'
  end
  
  # Users
  # -------------------------------------------
  factory :dmp_admin, class: User do
    email 'dmp_admin_test@ucop.edu'
    login_id 'dmp_admin'
    first_name 'DMP' 
    last_name 'ADMIN'
    password 'secret123' 
    password_confirmation 'secret123'
  end
  factory :institutional_admin, class: User do
    email 'dmp_institutional_admin_test@ucop.edu'
    login_id 'institutional_admin'
    first_name 'INSTITUTIONAL' 
    last_name 'ADMIN'
    password 'secret123' 
    password_confirmation 'secret123'
  end
  factory :institutional_reviewer, class: User do
    email 'dmp_institutional_reviewer_test@ucop.edu'
    login_id 'institutional_reviewer'
    first_name 'INSTITUTIONAL' 
    last_name 'REVIEWER'
    password 'secret123' 
    password_confirmation 'secret123'
  end
  factory :template_editor, class: User do
    email 'dmp_template_editor_test@ucop.edu'
    login_id 'template_editor'
    first_name 'TEMPLATE' 
    last_name 'EDITOR'
    password 'secret123' 
    password_confirmation 'secret123'
  end
  factory :resource_editor, class: User do
    email 'dmp_resource_editor_test@ucop.edu'
    login_id 'resource_editor'
    first_name 'RESOURCE' 
    last_name 'EDITOR'
    password 'secret123' 
    password_confirmation 'secret123'
  end
  
  # Templates
  # -------------------------------------------
  factory :requirements_template_1, class: RequirementsTemplate do
    name 'rt_1'
    active 'active'
    start_date '2014-04-17 05:07:50'
    visibility 'public'
    review_type 'no_review'
  end
  factory :requirements_template_2, class: RequirementsTemplate do
    name 'rt_2'
    active 'active'
    start_date '2016-01-27 05:07:50'
    visibility 'public'
    review_type 'no_review'
  end
  
  # Plans
  # -------------------------------------------
  factory :plan_public_1, class: Plan do
    name 'plan_public_1'
    visibility 'public'
  end
  factory :plan_public_2, class: Plan do
    name 'plan_public_2'
    visibility 'public'
  end
  factory :plan_institutional_1, class: Plan do
    name 'plan_institutional_1'
    visibility 'institutional'
  end
  factory :plan_institutional_2, class: Plan do
    name 'plan_institutional_2'
    visibility 'institutional'
  end
  factory :plan_institutional_3, class: Plan do
    name 'plan_institutional_3'
    visibility 'institutional'
  end
  factory :plan_private_1, class: Plan do
    name 'plan_private_1'
    visibility 'private'
  end
  factory :plan_private_2, class: Plan do
    name 'plan_private_2'
    visibility 'private'
  end
end