class PlansController < ApplicationController

  before_action :require_login, except: [:public, :show]
  #note show will need to be protected from logins in some cases, but only from non-public plan viewing
  before_action :set_plan, only: [:show, :edit, :update, :destroy, :publish, :export, :details, :preview]

  # GET /plans
  # GET /plans.json
  def index
   user_id = current_user.id
   plan_ids = UserPlan.where(user_id: user_id).pluck(:plan_id) unless user_id.nil?
   @plans = Plan.where(id: plan_ids)

    case params[:scope]
      when "all"
        @plans = @plans.page(params[:page]).per(1000)
      when "all_limited"
        @plans = @plans.page(params[:page]).per(5)
      when "coowned"
        @plans = @plans.coowned.page(params[:page]).per(5)
      when "approved"
        @plans = @plans.approved.page(params[:page]).per(5)
      when "submitted"
        @plans = @plans.submitted.page(params[:page]).per(5)
      when "rejected"
        @plans = @plans.rejected.page(params[:page]).per(5)
      else
        @plans = @plans.order(created_at: :asc).page(params[:page]).per(5)
    end

    @planstates = PlanState.page(params[:page]).per(5)
    count
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
    render(layout: "clean")
  end

  # GET /plans/new
  def new
    @plan = Plan.new
    @comment = Comment.new
  end

  # POST /plans
  # POST /plans.json
  def create
    @plan = Plan.new(plan_params)
    respond_to do |format|
      if @plan.save
        UserPlan.create!(user_id: current_user.id, plan_id: @plan.id, owner: true)
        PlanState.create!(plan_id: @plan.id, state: :new, user_id: current_user.id )
        format.html { redirect_to edit_plan_path(@plan), notice: 'Plan was successfully created.' }
        format.json { render action: 'show', status: :created, location: @plan }
      else
        format.html { render action: 'new' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /plans/1/edit
  def edit
    @comment = Comment.new
    comments = Comment.where(plan_id: @plan.id, user_id: current_user.id)
    @reviewer_comments = comments.where(visibility: :reviewer)
    @owner_comments = comments.where(visibility: :owner)
    @plan_states = @plan.plan_states
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to edit_plan_path(@plan), notice: 'Plan was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    @plan.destroy
    respond_to do |format|
      format.html { redirect_to plans_url }
      format.json { head :no_content }
    end
  end

  def template_information
    if !safe_has_role?(Role::DMP_ADMIN)
      user_plans = UserPlan.where(user_id: current_user.id)
      plan_ids=user_plans.pluck(:plan_id)
      @plans = Plan.page(params[:page]).per(5)
    else
      @plans = Plan.page(params[:page]).per(5)
    end
  end

  def copy_existing_template
    @comment = Comment.new
    comments = Comment.all
    id = params[:plan].to_i unless params[:plan].blank?
    plan = Plan.where(id: id).first
    @plan = plan.dup
    render action: "copy_existing_template"
  end

# To be completed
  # def add_coowner

  # end

  def export

  end

  def publish

  end

  def review_dmps
    if safe_has_role?(Role::INSTITUTIONAL_REVIEWER)
      user_id = current_user.id
      user_plans = UserPlan.where(user_id: user_id).pluck(:id)
      @plans = Plan.where(id: user_plans)
    end
    if safe_has_role?(Role::DMP_ADMIN)
      @plans = Plan.all
    end

    case params[:scope]
      when "all"
        @plans = @plans.page(params[:page])
      else
        @plans = @plans.order(created_at: :asc).page(params[:page]).per(5)
    end
  end

  def select_dmp_template
    #TODO  Need to create correct scope for viwing public templates and other things, code may also be refactored
    req_temp = RequirementsTemplate.includes(:institution)
    valid_buckets = nil
    if current_user.has_role?(Role::DMP_ADMIN)
      #all records
    elsif current_user.has_role?(Role::TEMPLATE_EDITOR) || current_user.has_role?(Role::INSTITUTIONAL_ADMIN)
      req_temp = req_temp.where(institution_id: current_user.institution.subtree_ids)
      valid_buckets = current_user.institution.child_ids
      base_inst = current_user.institution.id
      valid_buckets = [ current_user.institution.id ] if valid_buckets.length < 1
    else
      @rt_tree = {}
      return
    end
    if !params[:q].blank?
      req_temp = req_temp.name_search_terms(params[:q])
    end
    if !params[:s].blank? && !params[:e].blank?
      req_temp = req_temp.letter_range(params[:s], params[:e])
    end
    process_requirements_template(req_temp, valid_buckets)

    @back_to = plan_template_information_path
    @back_text = "<< Create New DMP"
    @submit_to = new_plan_path
    @submit_text = "DMP Overview Page >>"
  end

  def details
    template_id = @plan.requirements_template_id
    @requirements_template = RequirementsTemplate.find(template_id)
    @requirements = @requirements_template.requirements
    if params[:requirement_id].blank?
      requirement = @requirements_template.first_question
      if requirement.nil?
        redirect_to(resource_contexts_path, :notice =>
            "The DMP template you are attempting to customize has no requirements. A template must contain at least one requirement. \"#{@requirements_template.name}\" needs to be fixed before you may continue customizing it.") and return
      end
      params[:requirement_id] = requirement.id.to_s
    end
    @requirement = Requirement.find(params[:requirement_id]) unless params[:requirement_id].blank?
    @resource_contexts = ResourceContext.where(requirement_id: @requirement.id, institution_id: current_user.institution_id, requirements_template_id: @requirements_template.id)
    @guidance_resources = display_text(@resource_contexts)
    @url_resources = display_value(@resource_contexts)
    @suggested_resources = display_suggested(@resource_contexts)
    @example_resources = display_example(@resource_contexts)
    @response = Response.where(plan_id: @plan.id, requirement_id: @requirement.id).first
    if @response.nil?
      @response = Response.new
    end

    @next_requirement = @requirements[@requirements.index(@requirement) + 1]
    if @next_requirement.nil?
      ## would go back to the 1st Requirement in the list
      @next_requirement_id = @requirements_template.first_question.id
    else
      ## traverse through the next requirement in the list
      @next_requirement_id = @next_requirement.id
    end
  end

  def change_visibility
    id = params[:plan_id].to_i unless params[:plan_id].blank?
    plan = Plan.find(id)
    plan.visibility = params[:visibility]
    respond_to do |format|
      if plan.save!
        format.html { redirect_to edit_plan_path(plan)}
        format.js
      end
    end
  end

  def public
    @plans = Plan.public_visibility
    if params[:page] != 'all' then
      unless params[:s].blank? || params[:e].blank?
        @plans = @plans.letter_range(params[:s], params[:e])
      end
      unless params[:q].blank? then
        terms = params[:q].split.map {|t| "%#{t}%"}
        @plans = @plans.joins(:institution).joins(:users).where.
          any_of(["plans.name LIKE ?", terms],
                 ["institutions.full_name LIKE ?", terms],
                 ["users.last_name LIKE ? OR users.first_name LIKE ?", terms, terms])
      end
      @plans = @plans.page(params[:page]).per(10)
    else
      @plans = @plans.page(0).per(9999)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_params
      params.require(:plan).permit(:name, :requirements_template_id, :solicitation_identifier, :submission_deadline, :visibility, :current_plan_state_id)
    end

    def count
      @all = @plans.count
      @owned = @plans.owned.count
      @coowned = @plans.coowned.count
      @approved = @plans.approved.count
      @submitted = @plans.submitted.count
      @rejected = @plans.rejected.count
    end

    def display_text(resource_contexts)
      resources = Array.new
      @resource_contexts.each do |resource_context|
        id  = resource_context.resource_id
        resource = Resource.find(id)
        if resource.resource_type == :help_text
          resources << resource
        end
      end
      return resources
    end

    def display_value(resource_contexts)
      resources = Array.new
      @resource_contexts.each do |resource_context|
        id  = resource_context.resource_id
        resource = Resource.find(id)
        if resource.resource_type == :actionable_url
          resources << resource
        end
      end
      return resources
    end

    def display_suggested(resource_contexts)
      resources = Array.new
      @resource_contexts.each do |resource_context|
        id  = resource_context.resource_id
        resource = Resource.find(id)
        if resource.resource_type == :suggested_response
          resources << resource
        end
      end
      return resources
    end

    def display_example(resource_contexts)
      resources = Array.new
      @resource_contexts.each do |resource_context|
        id  = resource_context.resource_id
        resource = Resource.find(id)
        if resource.resource_type == :example_response
          resources << resource
        end
      end
      return resources
    end
end
