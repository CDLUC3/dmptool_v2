class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  # GET /plans
  # GET /plans.json
  def index
    if !safe_has_role?(Role::DMP_ADMIN)
      user = current_user.id
      userplans = UserPlan.where(user_id: user.id)
      @plans = Plan.includes(:userplans).where('userplans.plan_id =?', 'userplans').references(:userplans)
    else
      @plans = Plan.all
    end

    case params[:scope]
      when "all"
        @plans = @plans.page(params[:page])
      # when "all_limited"
      #   @plans = @plans.page(params[:page]).per(5)
      # when "shared"
      #   @plans = @plans.active.page(params[:page]).per(5)
      # when "approved"
      #   @plans = @plans.inactive.page(params[:page]).per(5)
      # when "submitted"
      #   @plans = @plans.public_visibility.page(params[:page]).per(5)
      # when "rejected"
      #   @plans = @plans.institutional_visibility.page(params[:page]).per(5)
      else
        @plans = @plans.order(created_at: :asc).page(params[:page]).per(5)
    end
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
    render 'edit'
  end

  # GET /plans/new
  def new
    @plan = Plan.new
    @comment = @plan.comments.build
    @comments = @plan.comments
  end

  # GET /plans/1/edit
  def edit
    @comments = @plan.comments
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
      @plans = Plan.page(params[:page]).per(5)
    else
      user_plans = UserPlan.where(user_id: current_user.id)
      plan_ids=user_plans.pluck(:plan_id)
      @plans = Plan.page(params[:page]).per(5)
    end
  end

  def copy_existing_template
    id = params[:plan].to_i unless params[:plan].blank?
    plan = Plan.where(id: id).first
    @plan = plan.dup
    render action: "copy_existing_template"
  end

  def select_dmp_template

  end

# To be completed
  # def add_coowner

  # end

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
