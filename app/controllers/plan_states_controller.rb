class PlanStatesController < ApplicationController
before_action :require_login
before_action :set_plan, only: [:approved, :rejected, :submitted, :committed, :reviewed]

  def approved
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      review_plan_state(:approved) if (plan_state == :submitted || plan_state == :approved)
    else
      redirect_to perform_review_plan_path(@plan), notice: "You dont have permission to Approve this plan."
    end
  end

  #for informal review
  def reviewed
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      review_plan_state(:reviewed) if (plan_state == :submitted || plan_state == :approved)
    else
      redirect_to perform_review_plan_path(@plan), notice: "You dont have permission to Review this plan."
    end
  end

  def rejected
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      review_plan_state(:rejected) if (plan_state == :submitted || plan_state == :rejected)
    else
      redirect_to perform_review_plan_path(@plan), notice: "You dont have permission to Approve this plan."
    end
  end

  def submitted
    @responses = Array.new
    requirements_template = RequirementsTemplate.find(@plan.requirements_template_id)
    requirements = requirements_template.requirements
    count = requirements.where(obligation: :mandatory).count

    requirements.each do |r|
      response = nil
      if r.obligation == :mandatory
        response = Response.where(plan_id: @plan.id, requirement_id: @requirement.id).first
        return @responses << response
      end
    end
    if @responses.count == count
      create_plan_state(:submitted)
    else
      redirect_to preview_plan_path(@plan), notice: "Please complete all the mandatory Responses for the Plan to be Submitted."
    end
  end

  def committed
    @responses = Array.new
    requirements_template = RequirementsTemplate.find(@plan.requirements_template_id)
    requirements = requirements_template.requirements
    count = requirements.where(obligation: :mandatory).count

    requirements.each do |r|
      response = nil
      if r.obligation == :mandatory
        response = Response.where(plan_id: @plan.id, requirement_id: @requirement.id).first
        return @responses << response
      end
    end
    if @responses.count == count
      create_plan_state(:committed)
    else
      redirect_to preview_plan_path(@plan), notice: "Please complete all the mandatory Responses for the Plan to be Finished."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:plan_id])
    end

    def create_plan_state(state)
      unless @plan.current_plan_state == state
        plan_state = PlanState.create( plan_id: @plan.id, state: state, user_id: current_user.id)
        @plan.current_plan_state_id = plan_state.id
        redirect_to preview_plan_path(@plan), notice: "The Plan is set to #{state}."
      else
        redirect_to preview_plan_path(@plan), notice: "The Plan is already set to #{state}."
      end
    end

    def review_plan_state(state)
      unless @plan.current_plan_state == state
        plan_state = PlanState.create( plan_id: @plan.id, state: state, user_id: current_user.id)
        @plan.current_plan_state_id = plan_state.id
        redirect_to perform_review_plan_path(@plan), notice: "The Plan is set to #{state}."
      else
        redirect_to perform_review_plan_path(@plan), notice: "The Plan is already set to #{state}."
      end
    end
end
