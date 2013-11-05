class DashboardController < ApplicationController
  
  #show the default dashboard with get request
  def show
    @simple_roles = current_user.roles.map {|i| i.name}
    if @simple_roles.include?('institutional_reviewer')
      @pending_review = 0
      PlanState::PENDING_REVIEW_STATES.each{|s| @pending_review += current_user.institution.plans_by_state(s).count}
      @finished_review = 0
      PlanState::FINISHED_REVIEW_STATES.each{|s| @finished_review += current_user.institution.plans_by_state(s).count}
    end
  end
end
