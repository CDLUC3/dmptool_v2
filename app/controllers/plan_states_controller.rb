class PlanStatesController < ApplicationController
before_action :require_login
before_action :set_plan, only: [:approved, :rejected, :submitted, :committed, :reviewed]

  def approved
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      review_plan_state(:approved) if (plan_state == :submitted || plan_state == :approved)
    else
      flash[:error] =  "You dont have permission to Approve this plan."
      redirect_to perform_review_plan_path(@plan)
    end
  end

  #for informal review
  def reviewed
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      if (plan_state == :submitted || plan_state == :approved || plan_state == :reviewed)
        review_plan_state(:reviewed) and return
      else
        flash[:error] =  "You can't review the plan from it's current state."
        redirect_to perform_review_plan_path(@plan) and return
      end
    else
      flash[:error] =  "You don't have permission to Review this plan."
      redirect_to perform_review_plan_path(@plan) and return
    end
  end

  def rejected(plan_id)
    @plan = Plan.find(@plan_id)
    plan_state = PlanState.find(@plan.current_plan_state_id).state
    if user_role_in?(:institutional_reviewer, :institutional_admin, :dmp_admin)
      review_plan_state(:rejected) if (plan_state == :submitted || plan_state == :rejected)
    else
      flash[:error] =  "You dont have permission to Approve this plan."
      redirect_to perform_review_plan_path(@plan)
    end
  end

  def reject_with_comments
    @plan_id = params[:comment][:plan_id]
    @comment = Comment.new(comment_params)
    @comment.save
    rejected(@plan_id)
  end

  def submitted
    unless @plan.nil?
      requirements_template = RequirementsTemplate.find(@plan.requirements_template_id)
      requirements = requirements_template.requirements
      count = requirements.where(obligation: :mandatory).count
      @responses = Requirement.requirements_with_mandatory_obligation(@plan.id, requirements_template.id)
      if @responses.count == count
        create_plan_state(:submitted)
      else
        flash[:error] =  "Please complete all the mandatory Responses for the Plan to be Submitted."
        redirect_to preview_plan_path(@plan)
      end
    end
  end

  def committed
    @responses = Array.new
    unless @plan.nil?
      requirements_template = RequirementsTemplate.find(@plan.requirements_template_id)
      requirements = requirements_template.requirements
      count = requirements.where(obligation: :mandatory).count
      @responses = Requirement.requirements_with_mandatory_obligation(@plan.id, requirements_template.id)
      if @responses.count == count
        create_plan_state(:committed)
      else
        flash[:error] =  "Please complete all the mandatory Responses for the Plan to be Finished."
        redirect_to preview_plan_path(@plan)
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:plan_id])
    end

    def create_plan_state(state)

      if state == :submitted
        if @plan.requirements_template.review_type == :informal_review
          @notice_1 = "This plan has been submitted for feedback from an administrator at your institution."
          @notice_2 = "This Plan has been already submitted for feedback."
          
        else
          @notice_1 = "This plan has been submitted for feedback from an administrator at your institution."
          @notice_2 = "This Plan has been already submitted for feedback."
        end
      else
        @notice_1 = "The Plan has been #{state == :committed ? "Completed" : state}."
        @notice_2 = "The Plan has already been #{state== :committed ? "Completed" : state}."
      end
      unless @plan.current_plan_state == state
        plan_state = PlanState.create( plan_id: @plan.id, state: state, user_id: current_user.id)
        @plan.current_plan_state_id = plan_state.id
        redirect_to preview_plan_path(@plan), notice: @notice_1
      else
        redirect_to preview_plan_path(@plan), alert: @notice_2
      end
    end

    def review_plan_state(state)

      if state == :submitted
        if @plan.requirements_template.review_type == :informal_review
          @notice_1 = "This plan has been submitted for feedback from an administrator at your institution."
          @notice_2 = "This Plan has been already submitted for feedback."
          
        else
          @notice_1 = "This plan has been submitted for feedback from an administrator at your institution."
          @notice_2 = "This Plan has been already submitted for feedback."
        end
      else
        @notice_1 = "The Plan has been #{state== :committed ? "Completed" : state}."
        @notice_2 = "The Plan has already been #{state== :committed ? "Completed" : state}."
      end
      unless @plan.current_plan_state == state
        plan_state = PlanState.create( plan_id: @plan.id, state: state, user_id: current_user.id)
        @plan.current_plan_state_id = plan_state.id
        redirect_to perform_review_plan_path(@plan), notice: @notice_1
      else
        redirect_to perform_review_plan_path(@plan), alert: @notice_2
      end
    end

    def comment_params
      params.require(:comment).permit(:user_id, :plan_id, :value, :visibility, :comment_type)
    end

end
