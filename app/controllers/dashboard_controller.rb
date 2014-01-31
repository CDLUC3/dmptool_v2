class DashboardController < ApplicationController
  
  #show the default dashboard with get request
  def show
    if safe_has_role?(Role::INSTITUTIONAL_REVIEWER) || safe_has_role?(Role::DMP_ADMIN) 
      @pending_review = current_user.institution.plans_by_state(PlanState::PENDING_REVIEW_STATES).count
      @finished_review = current_user.institution.plans_by_state(PlanState::FINISHED_REVIEW_STATES).count
    end
    if safe_has_role?(Role::TEMPLATE_EDITOR) || safe_has_role?(Role::DMP_ADMIN) || safe_has_role?(Role::INSTITUTIONAL_ADMIN)
      @requirements_templates = current_user.institution.requirements_templates_deep.where(visibility: 'institutional').count
      @public_requirements_templates = current_user.institution.requirements_templates_deep.where(visibility: 'public').count
    end
    if safe_has_role?(Role::RESOURCE_EDITOR) || safe_has_role?(Role::DMP_ADMIN) || safe_has_role?(Role::INSTITUTIONAL_ADMIN)
      #@resource_templates = current_user.institution.resource_templates_deep.count
    end
  end
  
  def test
    @rt = RequirementsTemplate.find(1)
    @root_requirements = @rt.requirements.where("ancestry IS NULL")
  end
end
