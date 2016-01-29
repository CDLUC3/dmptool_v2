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
  end
end

# -----------------------------------------------------------------------------
def test_authorized(users, targets, validations)
  targets.each do |target|
    
    # Run tests for each of the roles that should have access
    users.each do |user|
      get target, {}, { 'Accept' => 'application/json',
                        'Authorization' => encode(user.auth_token) }
                      
      validations.call(user.login_id, response)
    end
  end
end

# -----------------------------------------------------------------------------
def setup_test_data
  # Institutions
  # ---------------------------------------------
  @institution_1 = create(:institution_1)
  @institution_2 = create(:institution_2)
  @institution_3 = create(:institution_3)
  
  @institutions = [@institution_1, @institution_2, @institution_3]
  
  # Users and Roles
  # ---------------------------------------------
  @dmp_admin = create(:dmp_admin, institution_id: @institution_1.id)
  @dmp_admin.update_authorizations([Role::DMP_ADMIN])
  @institutional_admin = create(:institutional_admin, institution_id: @institution_2.id)
  @institutional_admin.update_authorizations([Role::INSTITUTIONAL_ADMIN])
  
  @institutional_reviewer = create(:institutional_reviewer, institution_id: @institution_2.id)
  @institutional_reviewer.update_authorizations([Role::INSTITUTIONAL_REVIEWER])
  @template_editor = create(:template_editor, institution_id: @institution_2.id)
  @template_editor.update_authorizations([Role::TEMPLATE_EDITOR])
  @resource_editor = create(:resource_editor, institution_id: @institution_2.id)
  @resource_editor.update_authorizations([Role::RESOURCE_EDITOR])
  @resource_editor2 = create(:resource_editor2, institution_id: @institution_3.id)
  @resource_editor2.update_authorizations([Role::RESOURCE_EDITOR])
  
  @users = [@dmp_admin, @institutional_admin, @institutional_reviewer, @template_editor, @resource_editor]
  
  @users_with_admin_access = [@dmp_admin, @institutional_admin]
  @users_without_admin_access = [@institutional_reviewer, @template_editor, @resource_editor]
  @users_with_institutional_access = [@institutional_admin, @institutional_reviewer, @template_editor, @resource_editor]
  
  # Requirements Templates
  # ---------------------------------------------
  @requirements_template_public = create(:requirements_template_public, institution_id: @institution_1.id)
  @requirements_template_institutional = create(:requirements_template_institutional, institution_id: @institution_2.id)
  @requirements_template_institutional_2 = create(:requirements_template_institutional, institution_id: @institution_3.id)

  @templates = [@requirements_template_public, @requirements_template_institutional]
  @templates_public = [@requirements_template_public]
  @templates_institutional = [@requirements_template_institutional]
  
  # Plans
  # ---------------------------------------------
  original_plan = Plan.first
  @plan_public_1 = create(:plan_public_1, requirements_template_id: @requirements_template_public.id, original_plan_id: original_plan.id)
  @plan_public_2 = create(:plan_public_2, requirements_template_id: @requirements_template_institutional.id, original_plan_id: original_plan.id)
  
  @plan_institutional_1 = create(:plan_institutional_1, requirements_template_id: @requirements_template_public.id, original_plan_id: original_plan.id)
  @plan_institutional_2 = create(:plan_institutional_2, requirements_template_id: @requirements_template_public.id, original_plan_id: original_plan.id)
  @plan_institutional_3 = create(:plan_institutional_3, requirements_template_id: @requirements_template_institutional.id, original_plan_id: original_plan.id)
  @plan_institutional_3 = create(:plan_institutional_4, requirements_template_id: @requirements_template_institutional_2.id, original_plan_id: original_plan.id)
  
  @plan_private_1 = create(:plan_private_1, requirements_template_id: @requirements_template_public.id, original_plan_id: original_plan.id)
  @plan_private_2 = create(:plan_private_2, requirements_template_id: @requirements_template_institutional.id, original_plan_id: original_plan.id)
  @plan_private_3 = create(:plan_private_3, requirements_template_id: @requirements_template_institutional.id, original_plan_id: original_plan.id)
  
  @plans = [@plan_public_1, @plan_public_2, 
            @plan_institutional_1, @plan_institutional_2, @plan_institutional_3,
            @plan_private_1, @plan_private_2, @plan_private_3]
  
  @plans_public = [@plan_public_1, @plan_public_2]
  @plans_institutional = [@plan_institutional_1, @plan_institutional_2, @plan_institutional_3]
  @plans_private = [@plan_private_1, @plan_private_2, @plan_private_3]
  
  # Plan Owners/Coowners --- there is probably a more elegant way to do this
  # ---------------------------------------------
  create(:plan_owner, plan: @plan_public_1, user: @dmp_admin)
  create(:plan_owner, plan: @plan_public_2, user: @institutional_admin)
  create(:plan_owner, plan: @plan_institutional_1, user: @institutional_admin)
  create(:plan_owner, plan: @plan_institutional_2, user: @institutional_admin)
  create(:plan_owner, plan: @plan_institutional_3, user: @dmp_admin)
  create(:plan_owner, plan: @plan_institutional_4, user: @dmp_admin)
  create(:plan_owner, plan: @plan_private_1, user: @institutional_admin)
  create(:plan_owner, plan: @plan_private_2, user: @dmp_admin)
  create(:plan_owner, plan: @plan_private_3, user: @dmp_admin)  

  # Coownership
  create(:plan_coowner, plan: @plan_private_3, user: @institutional_admin)
  create(:plan_coowner, plan: @plan_private_2, user: @institutional_reviewer)
  create(:plan_coowner, plan: @plan_private_2, user: @template_editor)
  create(:plan_coowner, plan: @plan_private_2, user: @resource_editor)
  
  # Institutional admin should have access to plans: 
  #  Because Public:  plan_public_1, plan_public_2,
  #  Because Institutional:  plan_institutional_1, plan_institutional_2
  #  Because Private Owned/Coowned:  plan_private_1, plan_private_3
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
module UserPlanEmail
  def email_coowner_added
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
  factory :resource_editor2, class: User do
    email 'dmp_resource_editor2_test@ucop.edu'
    login_id 'resource_editor2'
    first_name 'RESOURCE' 
    last_name 'EDITOR2'
    password 'secret123' 
    password_confirmation 'secret123'
  end
  
  # Templates
  # -------------------------------------------
  factory :requirements_template_public, class: RequirementsTemplate do
    name 'rt_public'
    active 'active'
    start_date '2014-04-17 05:07:50'
    visibility 'public'
    review_type 'no_review'
  end
  factory :requirements_template_institutional, class: RequirementsTemplate do
    name 'rt_institutional'
    active 'active'
    start_date '2016-01-27 05:07:50'
    visibility 'institutional'
    review_type 'no_review'
  end
  
  # Plans
  # -------------------------------------------
  factory :plan_public_1, class: Plan do
    name 'plan_public_1'
    visibility 'public'
    created_at Date.today
  end
  factory :plan_public_2, class: Plan do
    name 'plan_public_2'
    visibility 'public'
    created_at Date.today
  end
  factory :plan_institutional_1, class: Plan do
    name 'plan_institutional_1'
    visibility 'institutional'
    created_at Date.today
  end
  factory :plan_institutional_2, class: Plan do
    name 'plan_institutional_2'
    visibility 'institutional'
    created_at Date.today
  end
  factory :plan_institutional_3, class: Plan do
    name 'plan_institutional_3'
    visibility 'institutional'
    created_at Date.today
  end
  factory :plan_institutional_4, class: Plan do
    name 'plan_institutional_4'
    visibility 'institutional'
    created_at Date.today
  end
  factory :plan_private_1, class: Plan do
    name 'plan_private_1'
    visibility 'private'
    created_at Date.today
  end
  factory :plan_private_2, class: Plan do
    name 'plan_private_2'
    visibility 'private'
    created_at Date.today
  end
  factory :plan_private_3, class: Plan do
    name 'plan_private_3'
    visibility 'private'
    created_at Date.today
  end
  
  # Plan States
  # -------------------------------------------
  factory :plan_state_committed, class: PlanState do
    state :committed
  end
  
  # User Plans
  # -------------------------------------------
  factory :plan_owner, class: UserPlan do
    owner true
  end
  factory :plan_coowner, class: UserPlan do
    owner false
  end
end