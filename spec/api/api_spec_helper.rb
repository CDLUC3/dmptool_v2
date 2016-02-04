RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

# ---------------------------------------------------------------------------------
# HELPER INSTANCE VARIABLES
# ---------------------------------------------------------------------------------
#  @institutions                  <-- All 3 institutions
#  @users                         <-- All users - 1 user per role per institution
#  @users_with_admin_access       <-- All users with DMP_ADMIN or INSTITUTIONAL_ADMIN
#  @users_without_admin_access    <-- All users who are NOT a DMP_ADMIN or INSTITUTIONAL_ADMIN

#  @users_of_institution_1        <-- All users attached to institution_1
#  @users_of_institution_2        <-- All users attached to institution_2
#  @users_of_institution_3        <-- All users attached to institution_3

#  @users_with_dmp_admin_access
#  @users_with_institutional_admin_access
#  @users_with_institutional_reviewer_access
#  @users_with_template_editor_access
#  @users_with_resource_editor_access
#
#  Individual users can be accessed via:
#  @[role]_[institution]          <-- e.g. institutional_admin_institution_2
# ---------------------------------------------------------------------------------

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
  @insts, @institutions = {}, []
  
  # Create 3 instances of an Institution
  (1..3).each do |i|
    id = "institution_#{i}"
    
    FactoryGirl.define do
      factory id, class: Institution do
        full_name id
        contact_email "#{id}@cdlib.org"
      end
    end
    
    instance_variable_set("@#{id}", create(id))
    
    @institutions << instance_variable_get("@#{id}")
    @insts[id] = instance_variable_get("@#{id}")
  end
  
  # Users and Roles
  # ---------------------------------------------
  @roles = {dmp_admin: Role::DMP_ADMIN, 
            institutional_admin: Role::INSTITUTIONAL_ADMIN, 
            institutional_reviewer: Role::INSTITUTIONAL_REVIEWER, 
            template_editor: Role::TEMPLATE_EDITOR, 
            resource_editor: Role::RESOURCE_EDITOR}
  
  @users = []
  @users_with_admin_access = []
  @users_without_admin_access = []
  
  # Generate a set of users for each role at each institution
  @insts.each do |inst_name, institution|
    instance_variable_set("@users_of_#{inst_name}", [])
    
    @roles.each do |role_name, role|
      instance_variable_set("@users_with_#{role_name}_access", [])
      
      FactoryGirl.define do
        factory "#{role_name}_#{inst_name}", class: User do
          email "#{role_name}_#{inst_name}@cdlib.org"
          login_id "#{role_name}_#{inst_name}"
          first_name "#{role_name}" 
          last_name "#{inst_name}"
          password 'secret123' 
          password_confirmation 'secret123'
        end
      end
    
      instance_variable_set("@#{role_name}_#{inst_name}", create("#{role_name}_#{inst_name}", 
                                                                  institution_id: institution.id))
      
      user = instance_variable_get("@#{role_name}_#{inst_name}")
      
      # Add the user to the appropriate arrays
      @users << user

      instance_variable_get("@users_of_#{inst_name}") << user
      instance_variable_get("@users_with_#{role_name}_access") << user
      
      if [:dmp_admin, :institutional_admin].include?(role_name)
        @users_with_admin_access << user
      else
        @users_without_admin_access << user
      end
    end
  end
  
  # Attach the users to their roles
  @users.each do |user|
    user.update_authorizations([@roles[:"#{user.first_name}"]])
  end

=begin     
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
=end
  # Requirements Templates
  # ---------------------------------------------
  @requirements_template_public = create(:requirements_template_public, institution_id: @institution_1.id)
  @requirements_template_institutional = create(:requirements_template_institutional, institution_id: @institution_2.id)
  @requirements_template_institutional_2 = create(:requirements_template_institutional, institution_id: @institution_3.id)
  @requirements_template_institutional_but_unused = create(:requirements_template_institutional_but_unused, institution_id: @institution_2.id)
  @requirements_template_institutional_inactive = create(:requirements_template_inactive, institution_id: @institution_2.id)

  @templates_accessable = [@requirements_template_public, @requirements_template_institutional]
  @templates_institutional = [@requirements_template_institutional, 
                              @requirements_template_institutional_but_unused]
  @templates_inaccessable = [@requirements_template_institutional_2, 
                             @requirements_template_institutional_but_unused, 
                             @requirements_template_institutional_inactive]
  
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
  factory :requirements_template_institutional_2, class: RequirementsTemplate do
    name 'rt_institutional_2'
    active 'active'
    start_date '2016-01-27 05:07:50'
    visibility 'institutional'
    review_type 'no_review'
  end
  factory :requirements_template_institutional_but_unused, class: RequirementsTemplate do
    name 'rt_institutional_but_unused'
    active 'active'
    start_date '2016-01-27 05:07:50'
    visibility 'institutional'
    review_type 'no_review'
  end
  factory :requirements_template_inactive, class: RequirementsTemplate do
    name 'rt_institutional_inactive'
    active 'inactive'
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