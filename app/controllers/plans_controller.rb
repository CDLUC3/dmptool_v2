class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy, :publish, :export]

  # GET /plans
  # GET /plans.json
  def index
    if !safe_has_role?(Role::DMP_ADMIN)
      user_id = current_user.id
      user_plans = UserPlan.where(user_id: user_id).pluck(:id) unless user_id.nil?
      @plans = Plan.where(id: user_plans)
    else
      @plans = Plan.all
    end

    case params[:scope]
      when "all"
        @plans = @plans.page(params[:page])
      when "all_limited"
        @plans = @plans.page(params[:page]).per(5)
      when "shared"
        @plans = @plans.shared.page(params[:page]).per(5)
      # when "approved"
      #   @plans = @plans.approved.page(params[:page]).per(5)
      # when "submitted"
      #   @plans = @plans.submitted.page(params[:page]).per(5)
      # when "rejected"
      #   @plans = @plans.rejected.page(params[:page]).per(5)
      else
        @plans = @plans.order(created_at: :asc).page(params[:page]).per(5)
    end

    @planstates = PlanState.page(params[:page]).per(5)
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
    render 'edit'
  end

  # GET /plans/new
  def new
    @plan = Plan.new
  end

  # GET /plans/1/edit
  def edit
  end

  # POST /plans
  # POST /plans.json
  def create
    @plan = Plan.new(plan_params)
    respond_to do |format|
      if @plan.save
        UserPlan.create!(user_id: current_user.id, plan_id: @plan.id, owner: true)
        PlanState.create!(plan_id: @plan.id, state: :new, user_id: current_user.id )
        format.html { redirect_to plans_path, notice: 'Plan was successfully created.' }
        format.json { render action: 'show', status: :created, location: @plan }
      else
        format.html { render action: 'new' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to plans_path, notice: 'Plan was successfully updated.' }
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
      user = current_user.id
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
    @institutions = current_user.institution.subtree
    @dmp_templates = RequirementsTemplate.public_visibility.includes(:institution)

    if params[:s] && params[:e]
      @dmp_templates = @dmp_templates.letter_range_by_institution(params[:s], params[:e])
    end

    if params[:q]
      @dmp_templates = @dmp_templates.search_terms(params[:q])
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
end
