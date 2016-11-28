require 'htmltoword'
require 'pandoc-ruby'

class PlansController < ApplicationController

  before_action :require_login, except: [:public, :show]
  before_action :set_user
  #note show will need to be protected from logins in some cases, but only from non-public plan viewing
  before_action :set_plan, only: [:show, :edit, :update, :destroy, :publish, :export, :details, :preview, :perform_review, :coowners]
  before_action :check_copy_plan_access, only: [:copy_existing_template]
  before_action :check_plan_access, only: [:edit, :update, :destroy, :details, :preview]

  before_action :check_read_only_plan_access, only: [:show]

  before_action :set_cache_buster, only: [:show]

  respond_to :docx


  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  # GET /plans
  # GET /plans.json
  def index
    @owned_plans = @user.owned_plans
    @coowned_plans = @user.coowned_plans
    plan_ids = UserPlan.where(user_id: @user.id).pluck(:plan_id) unless @user.id.nil?
    @plans = Plan.where(id: plan_ids)
    count

    @order_scope = params[:order_scope] || ""
    @scope = params[:scope] || ""
    @all_scope = params[:all_scope] || ""

    #to avoid sql injection
    @direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

    case @scope
      when "owned"
        @plans = @owned_plans
      when "coowned"
        @plans = @coowned_plans
      when "approved"
        @plans = @plans.approved
      when "submitted"
        @plans = @plans.submitted
      when "committed"
        @plans = @plans.committed
      when "rejected"
        @plans = @plans.rejected
      when "reviewed"
        @plans = @plans.reviewed
    end

    case @order_scope
      when "name"
        @plans = @plans.order('name'+ " " + @direction)
      when "owner"
        @plans = @plans.joins(:current_state, :users).
                  order('users.first_name'+ " " + @direction , 'users.last_name'+ " " + @direction)
      when "status"
        @plans = @plans.joins(:current_state).order('CONVERT(plan_states.state USING utf8)' + " " + @direction)
      when "visibility"
        @plans = @plans.order('visibility'+ " " + @direction)
      when "last_modification_date"
        @plans = @plans.order('updated_at'+ " " + @direction)
      else
        @plans = @plans.order(updated_at: :desc)
    end

    case @all_scope
      when "all"
        @plans = @plans.page(params[:page]).per(9999)
      else
        @plans = @plans.page(params[:page]).per(5)
    end

  end

  # GET /plans/1
  # GET /plans/1.json
  def show
    response.headers["Expires"] = 1.year.ago.httpdate
    response.etag = nil
    respond_to do |format|
      format.pdf do
        render :layout => false
      end
      #format.rtf do
      #  render :layout => false
      #end
      format.json do
        render :layout => false
      end
      format.html do
        render :layout => false
        # render(layout: "clean")S
      end
      format.docx do
        templ_path = File.join(Rails.root.to_s, 'public')
        str = render_to_string(:template => '/plans/show_docx.html.erb', :layout => false)
        converter = PandocRuby.new(str, :from => :html, :to => :docx, 'data-dir' => templ_path )
        headers["Content-Disposition"] = "attachment; filename=\"" + sanitize_for_filename(@plan.name) + ".docx\""
        render :text => converter.convert, :content_type=> 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      end
    end

  end

  # GET /plans/new
  def new
    @plan = Plan.new
    @comment = Comment.new
  end

  # POST /plans
  # POST /plans.json
  def create
    flash[:error] = []
    @plan = Plan.new(plan_params)
    respond_to do |format|
      if params[:save_and_dmp_details]
        if @plan.save
          UserPlan.create!(user_id: @user.id, plan_id: @plan.id, owner: true)
          PlanState.create!(plan_id: @plan.id, state: :new, user_id: @user.id )
          add_coowner_autocomplete
          @invalid_users.count > 1 ? @notice_1 = "Could not find the following users #{@invalid_users.join(', ')}." : @notice_1 = "Could not find the following user #{@invalid_users.join(', ')}."
          @existing_coowners.count > 1 ? @notice_2 = "The users chosen #{@existing_coowners.join(', ')} are already #{@item_description}s of this Plan." : @notice_2 = "The user chosen #{@existing_coowners.join(', ')} is already a #{@item_description} of this Plan."
          @notice_3 = "The user chosen #{@owner[0].to_s} is the owner of the Plan. An owner cannot be #{@item_description} for the same plan."
          
          if !@invalid_users.empty? && !@existing_coowners.empty? && !@owner.empty?
            format.html { flash[:error] << @notice_1 << @notice_2 << @notice_3
                  redirect_to details_plan_path(@plan)}
          elsif !@invalid_users.empty? && !@existing_coowners.empty?
            format.html { flash[:error] << @notice_1 << @notice_2
                  redirect_to details_plan_path(@plan)}
          elsif !@existing_coowners.empty? && !@owner.empty?
            format.html { flash[:error] << @notice_2 << @notice_3
                  redirect_to details_plan_path(@plan)}
          elsif !@invalid_users.empty? && !@owner.empty?
            format.html { flash[:error] << @notice_1 << @notice_3
                  redirect_to details_plan_path(@plan)}
          elsif !@invalid_users.empty?
            format.html { flash[:error] << @notice_1
                  redirect_to details_plan_path(@plan)}
          elsif !@existing_coowners.empty?
            format.html { flash[:error] << @notice_2
                  redirect_to details_plan_path(@plan)}
          elsif !@owner.empty?
            format.html { flash[:error] << @notice_3
                  redirect_to details_plan_path(@plan)}
          else
          format.html { flash[:notice] = "Plan was successfully created."
                  redirect_to details_plan_path(@plan)}
          format.json { head :no_content }
          end
        else
          add_coowner_autocomplete
          format.html { render action: 'new' }
          format.json { render json: @plan.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /plans/1/edit
  def edit
    @customization_review  = precendence_review_type
    @template_review = precendence_template_review_type
    set_comments
    coowners
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
    flash[:error] = []
    @customization_review  = precendence_review_type
    @template_review = precendence_template_review_type
    set_comments
    coowners
    add_coowner_autocomplete
    @invalid_users.count > 1 ? @notice_1 = "Could not find the following users #{@invalid_users.join(', ')}." : @notice_1 = "Could not find the following user #{@invalid_users.join(', ')}."
    @existing_coowners.count > 1 ? @notice_2 = "The users chosen #{@existing_coowners.join(', ')} are already #{@item_description}s of this Plan." : @notice_2 = "The user chosen #{@existing_coowners.join(', ')} is already a #{@item_description} of this Plan."
    @notice_3 = "The user chosen #{@owner[0].to_s} is the owner of the Plan. An owner cannot be #{@item_description} for the same plan."
    respond_to do |format|
      if !@invalid_users.empty? && !@existing_coowners.empty? && !@owner.empty?
        format.html { flash[:error] << @notice_1 << @notice_2 << @notice_3
              redirect_to edit_plan_path(@plan)}
      elsif !@invalid_users.empty? && !@existing_coowners.empty?
        format.html { flash[:error] << @notice_1 << @notice_2
              redirect_to edit_plan_path(@plan)}
      elsif !@existing_coowners.empty? && !@owner.empty?
        format.html { flash[:error] << @notice_2 << @notice_3
              redirect_to edit_plan_path(@plan)}
      elsif !@invalid_users.empty? && !@owner.empty?
        format.html { flash[:error] << @notice_1 << @notice_3
              redirect_to edit_plan_path(@plan)}
      elsif !@invalid_users.empty?
        format.html { flash[:error] << @notice_1
              redirect_to edit_plan_path(@plan)}
      elsif !@existing_coowners.empty?
        format.html { flash[:error] << @notice_2
              redirect_to edit_plan_path(@plan)}
      elsif !@owner.empty?
        format.html { flash[:error] << @notice_3
              redirect_to edit_plan_path(@plan)}
      else
        if params[:save_changes] || !params[:save_and_dmp_details]
          if @plan.update(plan_params)
            format.html { flash[:notice] = "Plan was successfully updated."
                    redirect_to edit_plan_path(@plan)}
            format.json { head :no_content }
          else
            add_coowner_autocomplete
            format.html { render action: 'edit' }
            format.json { render json: @plan.errors, status: :unprocessable_entity }
          end
        end
        if !params[:save_changes] || params[:save_and_dmp_details]
          if @plan.update(plan_params)
          format.html { flash[:notice]
                  redirect_to details_plan_path(@plan)}
          format.json { head :no_content }
          else
            add_coowner_autocomplete
            format.html { render action: 'edit' }
            format.json { render json: @plan.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    user_plan_ids  = UserPlan.where(plan_id: @plan.id, owner: false).pluck(:user_id)
    if user_plan_ids.include?(@user.id) && !user_role_in?(:dmp_admin, :institutional_admin)
      flash[:error] =  "A Co-Owner cannot delete a Plan."
      redirect_to :back
    else
      user_plans = UserPlan.where(plan_id: @plan.id)
      plan_states = PlanState.where(plan_id: @plan.id)
      user_plans.delete_all
      plan_states.delete_all
      @plan.destroy
      redirect_to plans_url(order_scope: params[:order_scope], scope: params[:scope], all_scope: params[:all_scope], 
                        direction: params[:direction]), notice: "The plan has been successfully deleted."
    end
  end

  def template_information
    public_plans_ids = Plan.public_visibility.ids
    current_user_plan_ids = UserPlan.where(user_id: @user.id).pluck(:plan_id)
    
    institutionally_visible_plans_ids  = Plan.joins(:users)
          .where(users: {institution_id: @user.institution.root.subtree_ids})
          .institutional_visibility.pluck(:id)

    unit_visible_plans_ids = Plan.joins(:users)
          .where(users: {institution_id: @user.institution.subtree_ids})
          .unit_visibility.pluck(:id)
    
    test_visible_plans_ids = Plan.joins(:users)
          .where(users: {institution_id: @user.institution.subtree_ids})
          .test_visibility.pluck(:id)
                
    plans = (current_user_plan_ids + public_plans_ids + institutionally_visible_plans_ids + unit_visible_plans_ids).uniq
    @plans = Plan.where(id: plans)
    @plans = Kaminari.paginate_array(@plans).page(params[:page]).per(5)
  end

  def copy_existing_template
    @comment = Comment.new
    comments = Comment.all
    id = params[:plan].to_i unless params[:plan].blank?
    @original_plan_id = params[:plan].to_i
    plan = Plan.where(id: id).first
    @plan = plan.deep_clone except: :visibility, include: [:responses]
    
    render action: "copy_existing_template"
  end

  def perform_review
    set_comments
    @customization = ResourceContext.where(requirements_template_id: @plan.requirements_template_id, institution_id: @user.institution_id, resource_id: nil, requirement_id: nil).first
  end


  def review_dmps
    # if user_role_in?(:institutional_reviewer, :institutional_admin)
    if user_role_in?(:dmp_admin)
      @submitted_plans = Plan.plans_to_be_reviewed(Institution.all.ids)
      @approved_plans = Plan.plans_approved(Institution.all.ids)
      @rejected_plans = Plan.plans_rejected(Institution.all.ids)
      @reviewed_plans = Plan.plans_reviewed(Institution.all.ids)
      @plans = Plan.plans_per_institution(Institution.all.ids)

    elsif user_role_in?(:institutional_reviewer, :institutional_admin)
      institutions = Institution.find(@user.institution_id).subtree_ids
      @submitted_plans = Plan.plans_to_be_reviewed(institutions)
      @approved_plans = Plan.plans_approved(institutions)
      @rejected_plans = Plan.plans_rejected(institutions)
      @reviewed_plans = Plan.plans_reviewed(institutions)
      @plans = Plan.plans_per_institution(institutions)
    end

    review_count

    @order_scope = params[:order_scope]
    @scope = params[:scope]
    @all_scope = params[:all_scope]

    case @scope
      when "submitted"
        @plans = @submitted_plans
      when "approved"
        @plans = @approved_plans
      when "rejected"
        @plans = @rejected_plans
      when "reviewed"
        @plans = @reviewed_plans
      else
        @plans
    end

    case @order_scope
      when "DMPName"
        @plans = @plans.order(name: :asc)
      when "Owner"
        @plans = @plans.order_by_owner
      when "SubmissionDate"
        @plans = @plans.order(updated_at: :desc)
      when "Status"
        @plans = @plans.order_by_current_state
      else
        @plans = @plans.order(name: :asc)
    end

    case @all_scope
      when "all"
        @plans = @plans.page(params[:page]).per(9999)
      else
        @plans = @plans.page(params[:page]).per(5)
    end

  end


  def select_dmp_template
    req_temp = RequirementsTemplate.
                  includes(:institution).
                  where(active: true).
                  any_of(visibility: :public, institution_id: [@user.institution.root.subtree_ids])

    if !params[:q].blank?
      req_temp = req_temp.name_search_terms(params[:q])
    end
    if !params[:s].blank? && !params[:e].blank?
      req_temp = req_temp.letter_range(params[:s], params[:e])
    end

    process_requirements_template(req_temp)

    @back_to = plan_template_information_path
    @back_text = "<< Back"
    @submit_to = new_plan_path
    @submit_text = "Next >>"

  end

  def details
    template_id = @plan.requirements_template_id
    @requirements_template = RequirementsTemplate.find(template_id)
    unless @requirements_template.nil?
      @requirements = @requirements_template.requirements
      if params[:requirement_id].blank?
        requirement = @requirements_template.first_question
        last_requirement = @requirements_template.last_question
        if requirement.nil?
          flash[:error] =  "The DMP template you are attempting to customize has no requirements. A template must contain at least one requirement. \"#{@requirements_template.name}\" needs to be fixed before you may continue customizing it."
          redirect_to resource_contexts_path  and return
        end
        params[:requirement_id] = requirement.id.to_s
        params[:last_requirement_id] = last_requirement.id.to_s
      end
      @requirement = Requirement.find(params[:requirement_id]) unless params[:requirement_id].blank?
      @last_requirement = Requirement.find(params[:last_requirement_id]) unless params[:last_requirement_id].blank?
      @resource_contexts = ResourceContext.where(requirement_id: @requirement.id, institution_id: @user.institution_id, requirements_template_id: @requirements_template.id)

      @guidance_resources = Resource.joins(:resource_contexts).
      where("resources.resource_type = ?", :help_text).
      where("resource_contexts.requirement_id=?", @requirement.id).
      where("resource_contexts.institution_id =?", @user.institution_id).
      where("resource_contexts.requirements_template_id=?", @requirements_template.id)

      @url_resources = Resource.joins(:resource_contexts).
      where("resources.resource_type = ?", :actionable_url).
      where("resource_contexts.requirement_id=?", @requirement.id).
      where("resource_contexts.institution_id =?", @user.institution_id).
      where("resource_contexts.requirements_template_id=?", @requirements_template.id)

      @suggested_resources = Resource.joins(:resource_contexts).
      where("resources.resource_type = ?", :suggested_response).
      where("resource_contexts.requirement_id=?", @requirement.id).
      where("resource_contexts.institution_id =?", @user.institution_id).
      where("resource_contexts.requirements_template_id=?", @requirements_template.id)

      @example_resources = Resource.joins(:resource_contexts).
      where("resources.resource_type = ?", :example_response).
      where("resource_contexts.requirement_id=?", @requirement.id).
      where("resource_contexts.institution_id =?", @user.institution_id).
      where("resource_contexts.requirements_template_id=?", @requirements_template.id)

      @response = Response.where(plan_id: @plan.id, requirement_id: @requirement.id).first
      if @response.nil?
        @response = Response.new
      end
      next_requirement_id = @requirement.next_requirement_not_folder
      unless next_requirement_id.nil?
        ## would go back to the 1st Requirement in the list
        #TO DO: save previous requirements HERE
        @next_requirement_id = next_requirement_id
      else
        ## traverse through the next requirement in the list
        @next_requirement_id = @requirement.id
      end
    end
  end

  def change_visibility
    id = params[:plan_id].to_i unless params[:plan_id].blank?
    plan = Plan.find(id)
    plan.visibility = params[:visibility]
    respond_to do |format|
      if plan.save
        format.html { redirect_to :back }
        format.js
      end
    end
  end

  def confirm_visibility
    id = params[:plan_id].to_i unless params[:plan_id].blank?
    @plan = Plan.find(id)
    @plan.visibility = params[:visibility]
    if @plan.save
      # Change the plan's status to committed
      @responses = Array.new

      requirements_template = RequirementsTemplate.find(@plan.requirements_template_id)
      requirements = requirements_template.requirements
      count = requirements.where(obligation: :mandatory).count
      @responses = Requirement.requirements_with_mandatory_obligation(@plan.id, requirements_template.id)
      
      if @responses.count == count
        unless @plan.current_plan_state == :committed
          plan_state = PlanState.create(plan_id: @plan.id, state: :committed, user_id: current_user.id)
          @plan.current_plan_state_id = plan_state.id
          redirect_to preview_plan_path(@plan), notice: "The Plan has been Completed"
        else
          redirect_to preview_plan_path(@plan), alert: "The Plan has already been Completed"
        end
      else
        flash[:error] =  "Please complete all the mandatory Responses for the Plan to be Finished."
        redirect_to preview_plan_path(@plan)
      end
      
    end
  end

  def preview
    @plan = Plan.find(params[:id])
    @coowners = @plan.coowners
    @customization_review  = precendence_review_type
    @template_review = precendence_template_review_type
  end

  def public

    # gets parameters for public table
    public_params = {}
    params.slice("public:order_scope", "public:all_scope", "public:page")
          .each{|k,v| public_params[ k.partition(/^[a-z_]+\:/)[2] ] = v }

    # gets parameters for institutional table
    inst_params = {}
    params.slice("institutional:order_scope", "institutional:all_scope", "institutional:page")
          .each{|k,v| inst_params[ k.partition(/^[a-z_]+\:/)[2] ] = v }

    @plans = Plan.joins( {:users => :institution} ).joins(:requirements_template)
          .where("user_plans.owner = 1").public_visibility
    @inst_plans = Plan.joins( {:users => :institution} ).joins(:requirements_template)
          .where("user_plans.owner = 1").institutional_visibility

    @unit_plans = Plan.joins( {:users => :institution} ).joins(:requirements_template)
          .where("user_plans.owner = 1").where(visibility: :unit)

    @test_plans = Plan.joins( {:users => :institution} ).joins(:requirements_template)
        .where("user_plans.owner = 1").test_visibility

    @show_institution = false
    
    if current_user

      (user_role_in?(:dmp_admin) || current_user.institution.has_children? || current_user.institution.parent ) ? @show_institution = true : @show_institution = false   

      #show institutional for my institution
      @inst_plans_ids = @inst_plans.where("users.institution_id IN (?)", current_user.institution.root.subtree_ids).pluck(:id)

      @unit_plans_ids = @unit_plans.where("users.institution_id IN (?)", current_user.institution.subtree_ids).pluck(:id)

      if  @unit_plans_ids == [] && @inst_plans_ids != []
        @inst_plans = Plan.where(id: [@inst_plans_ids])
      elsif @inst_plans_ids == [] && @unit_plans_ids != []
         @inst_plans = Plan.where(id: [@unit_plans_ids])
      elsif @inst_plans_ids == [] && @unit_plans_ids == []
         @inst_plans = nil
      else 
        @inst_plans = Plan.where(id: [@inst_plans_ids, @unit_plans_ids])
      end  
         
    else
      @inst_plans = nil
      @test_plans = nil
    end
    
    @plans = multitable(@plans, public_params)
    # if @inst_plans
      @inst_plans = multitable(@inst_plans, inst_params)
    # end

    unless params[:s].blank? || params[:e].blank?
      @plans = @plans.letter_range(params[:s], params[:e])
    end
    unless params[:q].blank?
      @plans = @plans.search_terms(params[:q])
    end

  end


  def add_coowner_autocomplete
    invalid_users = Array.new
    existing_coowners  = Array.new
    owners = Array.new
    if @plan.blank? or @plan.id.blank?
      @invalid_users, @existing_coowners, @owner = invalid_users, existing_coowners, owners
      return # can't add a user to a plan that hasn't been created yet
    end
    u_name, = nil
    params.each do |k,v|
      u_name = v if k.end_with?('_name')
    end
    item_description = params[:item_description]
    unless u_name.blank?
      u_name.split(',').each do |n|
        unless n.blank?
          m = n.match(/<?(\S+\@\S+\.[^ >]+)/)
          term = n
          user, email = nil, nil
          email = m[1] unless m.nil?
          user = User.find_by(email: email)
          owner = UserPlan.where(plan_id: @plan.id, user_id: user.id, owner: true).first unless user.nil?
          if user.nil?
            invalid_users << term
          elsif user.user_plans.where(plan_id: @plan.id, owner: false).count > 0
            existing_coowners << user.full_name
          elsif !owner.nil?
            owners << User.find(owner.user_id).full_name
          else
            userplan = UserPlan.create(owner: false, user_id: user.id, plan_id: @plan.id)
            userplan.save!
          end
        end
      end
    end
    @invalid_users, @existing_coowners, @owner = invalid_users, existing_coowners, owners
  end

  def delete_coowner
    @coowner = User.find(params[:coowner_id]) unless params[:coowner_id].nil?
    @plan = Plan.find(params[:plan_id]) unless params[:plan_id].nil?
    unless @coowner.nil?
      user_plan = UserPlan.where(user_id: @coowner.id, plan_id: @plan.id, owner: false).last
      user_plan.destroy
      respond_to do |format|
        format.html { redirect_to edit_plan_path(@plan), notice: "The selected Coowner associated with the Plan has been deleted successfully" }
        format.json { head :no_content }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      begin
        @plan = Plan.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to plans_path, error: "The Plan you were looking for does not exist."
        return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_params
      params.require(:plan).permit(:name, :requirements_template_id, :solicitation_identifier, :submission_deadline, 
                                  :visibility, :current_plan_state_id, :current_user_id, :original_plan_id, 
                                  responses_attributes: [:id, :plan_id, :requirement_id, :text_value, :numeric_value, 
                                    :date_value, :enumeration_id, :lock_version, :label_id])
    end

    def count
      @owned = @owned_plans.count
      @coowned = @coowned_plans.count
      @all = @owned + @coowned
      @approved = @plans.approved.count
      @submitted = @plans.submitted.count
      @committed = @plans.committed.count
      @rejected = @plans.rejected.count
      @reviewed = @plans.reviewed.count
    end

    def review_count
      @submitted = @submitted_plans.count
      @approved = @approved_plans.count
      @rejected = @rejected_plans.count
      @reviewed = @reviewed_plans.count
      @all = @submitted + @approved + @rejected + @reviewed
    end

    def set_comments
      @comment = Comment.new
      comments = Comment.where(plan_id: @plan.id)
      @reviewer_comments = comments.reviewer_comments.order('created_at DESC')
      @owner_comments = comments.owner_comments.order('created_at DESC')
      @all_comments = comments.order(created_at: :desc)
      @plan_states = @plan.plan_states
    end

    def coowners
      id = @plan.user_plans.where(owner: true).pluck(:user_id).first
      @planowner = User.find(id) unless id.nil?
      @coowners = Array.new
      user_plans = @plan.user_plans.where(owner: false)
      user_plans.each do |user_plan|
        id = user_plan.user_id
        @coowner = User.find(id)
        @coowners<< @coowner
      end
    end

    def set_user
      @user = current_user
    end

    def precendence_review_type
      @customization = ResourceContext.where(requirements_template_id: @plan.requirements_template_id, institution_id: @user.institution_id, resource_id: nil, requirement_id: nil).first
      if @customization.nil?
        return nil
      elsif @customization.review_type == :formal_review
        return "formal"
      elsif @customization.review_type == :informal_review
        return "informal"
      else
        return "no"
      end
    end

    def precendence_template_review_type
      if @plan.requirements_template.review_type.nil?
        return nil
      elsif @plan.requirements_template.review_type == :formal_review
        return "formal"
      elsif @plan.requirements_template.review_type == :informal_review
        return "informal"
      else
        return "no"
      end
    end

    def check_plan_access
      unless @user.id.nil?
        @plan = Plan.find(params[:id])
        user_plans = UserPlan.where(user_id: @user.id, plan_id: @plan.id)
        unless !user_plans.empty?
          flash[:error] = "You don't have access to this content."
          redirect_to plans_path # halts request cycle
        end
      else
        flash[:error] = "You need to be logged in."
        redirect_to root_url
      end
    end

    def check_copy_plan_access
    ## This params is from Copy Existing Template action
      if params[:plan] == "" || params[:plan].nil?
        flash[:error] = "Please select an existing Plan to copy."
        redirect_to plans_path
        
      # If the plan's template is not active then we cannot copy it
      elsif !Plan.find(params[:plan]).requirements_template.active
        flash[:error] = "That Plan was created from a template that is no longer active. Please select a more recent Plan to copy."
        redirect_to plans_path
        
      else
        @copy_plan = Plan.find(params[:plan])
        user_plans = UserPlan.where(user_id: @user.id, plan_id: @copy_plan.id)
        institutionally_visible_plans  = Plan.joins(:users).where('users.institution_id = ?',@user.institution_id).institutional_visibility
        public_plans = Plan.public_visibility
        copy_plans = user_plans + institutionally_visible_plans + public_plans
        unless !copy_plans.empty?
          flash[:error] = "You don't have access to this content."
          redirect_to plans_path # halts request cycle
        end
      end
    end


    def check_read_only_plan_access
      @plan = Plan.find(params[:id])
      if current_user 
        unless user_role_in?(:dmp_admin)
          case @plan.visibility
          when :private 
            redirect_to root_url, :flash=>{:error=>"You don't have access to this content."} unless current_user == @plan.owner || @plan.coowners.include?(current_user)
          when :institutional
            redirect_to root_url, :flash=>{:error=>"You don't have access to this content."} unless current_user.institution.root.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(current_user)
          when :unit 
            redirect_to root_url, :flash=>{:error=>"You don't have access to this content."} unless current_user.institution.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(current_user)
          else #this plan is public
            #do nothing
          end
        end
      else #(=> user is not logged in)
        unless @plan.visibility == :public
          flash[:error] = "You don't have access to this content."
          redirect_to root_url
        end 
      end
    end


    def multitable(collection, subparams)
      return nil if collection.nil?
      valid_sort = ["plan", "institution", "visibility",
                    "owner", "template"]


      if valid_sort.include?(subparams['order_scope'])

        case subparams['order_scope']
        when "plan"
          collection = collection.order(name: :asc) 
        when "template"
          collection = collection.joins(:requirements_template).order('requirements_templates.name ASC')
        when "institution"
          collection = collection.order_by_institution
        when "owner"
         collection = collection.order_by_owner
        when "visibility"
         collection = collection.order(visibility: :desc)
        else
          collection = collection.order(name: :asc)
        end             

      end

      if subparams['all_scope'] != 'all'
        p = ( subparams['page'].nil? ? 1 : subparams['page'].to_i )
        collection = collection.page(p).per(10)
      else
        collection = collection.page(0).per(9999)
      end
      return collection
    end
end
