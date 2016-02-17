require 'spec_helper'
# ---------------------------------------------------------------------------------
# HELPER INSTANCE VARIABLES - (last number in parenthesis is size of that var)
# ---------------------------------------------------------------------------------
#  @institutions                  <-- All 3 institutions
#  ------------------------------------------------------------------
#  @users                         <-- All users - 1 user per role per institution (15)
#  @users_with_admin_access       <-- All users with DMP_ADMIN or INSTITUTIONAL_ADMIN (6)
#  @users_without_admin_access    <-- All users who are NOT a DMP_ADMIN or INSTITUTIONAL_ADMIN (9)

#  @users_of_institution_N        <-- All users attached to the institution (5)

#  @users_with_dmp_admin_access   <-- All DMP_ADMINs (3)
#  @users_with_institutional_admin_access <-- All INSTITUTIONAL_ADMINs (3)
#  @users_with_institutional_reviewer_access <-- All INSTITUTIONAL_REVIEWERs (3)
#  @users_with_template_editor_access <-- All TEMPLATE_EDITORs (3)
#  @users_with_resource_editor_access <-- All RESOURCE_EDITORs (3)
#
#  Individual users can be accessed via:
#  @[role]_[institution]          <-- e.g. institutional_admin_institution_2 (1)
#  ------------------------------------------------------------------
#  @templates                     <-- All templates - 2 per institution per visibility (6)
#  @templates_with_public_visibility <-- All templates with public visibility (3)
#  @templates_with_institutional_visibility <-- All templates with institutional visibility (3)
#  @templates_for_institution_N <-- All templates for the institution (2)
#
# @template_[visibility]_[institution] <-- Individual template (e.g. @template_public_institution_3)
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
# -----------------------------------------------------------------------------

# Roles
# ---------------------------------------------
def get_roles
  return {dmp_admin: Role::DMP_ADMIN, 
          institutional_admin: Role::INSTITUTIONAL_ADMIN, 
          institutional_reviewer: Role::INSTITUTIONAL_REVIEWER, 
          template_editor: Role::TEMPLATE_EDITOR, 
          resource_editor: Role::RESOURCE_EDITOR}
end
        
# Institutions
# ---------------------------------------------
def create_test_institutions
  institutions = create_list(:api_institution, 3)
  institutions.map{|i| instance_variable_set("@#{i.full_name}", i)}
  
  institutions
end

# Users and Roles
# ---------------------------------------------
def create_test_user_per_role(institution, roles)
  counter = 0
  users = create_list(:api_user, roles.size, institution_id: institution.id)
  
  roles.each do |role_name, role|
    users[counter].update_authorizations([role])
    counter = counter + 1
  end
  
  users
end

# Requirements Templates
# ---------------------------------------------
def create_test_templates(institution)
  templates = []
  
  ['public', 'institutional'].each do |visibility|
    templates << create("api_#{visibility}_template", institution_id: institution.id)
  end
  
  templates
end

# Plans
# ---------------------------------------------
def create_test_plan_per_visibility(template, owner)
  plans = []
  
  ['public', 'institutional', 'private', 'unit'].each do |visibility|
    create_test_plan(template, visibility, owner, nil)
  end
  
  plans
end
# ---------------------------------------------
def create_test_plan(template, visibility, owner, coowner)
  original_plan = Plan.first
  
  plan = create("api_#{visibility}_plan", requirements_template_id: template.id,
                                          original_plan_id: original_plan.id)
                                   
  create(:api_plan_owner, plan: plan, user: owner)
  create(:api_plan_coowner, plan: plan, user: coowner) unless coowner.nil?
  
  plan
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
