class DashboardController < ApplicationController
  
  #show the default dashboard with get request
  def show
    @simple_roles = current_user.roles.map {|i| i.name}
    if @simple_roles.include?('institutional_reviewer')
      @pending_review = current_user.institution.plans_by_state(PlanState::PENDING_REVIEW_STATES).count
      @finished_review = current_user.institution.plans_by_state(PlanState::FINISHED_REVIEW_STATES).count
    end
  end
  
  def test
    @rt = RequirementsTemplate.find(1)
    @root_requirements = @rt.requirements.where("ancestry IS NULL")
  end
end
