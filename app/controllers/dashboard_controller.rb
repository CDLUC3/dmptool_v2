class DashboardController < ApplicationController

  before_action :require_login, only: [:show]

  #show the default dashboard with get request
  def show
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      @pending_review = current_user.institution.plans_by_state(PlanState::PENDING_REVIEW_STATES).count
      @finished_review = current_user.institution.plans_by_state(PlanState::FINISHED_REVIEW_STATES).count
    end
    if user_role_in?(:template_editor, :dmp_admin, :institutional_admin)
      @requirements_templates = current_user.institution.requirements_templates_deep.where(visibility: 'institutional').count
      @public_requirements_templates = current_user.institution.requirements_templates_deep.where(visibility: 'public').count
    end
    if user_role_in?(:resource_editor, :dmp_admin, :institutional_admin)
      #@resource_templates = current_user.institution.resource_templates_deep.count
    end
  end

  def test
    @rt = RequirementsTemplate.find(1)
    @root_requirements = @rt.requirements.where("ancestry IS NULL")
  end
end
