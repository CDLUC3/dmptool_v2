require 'rtf'

class RequirementsTemplatesController < ApplicationController

  before_action :require_login, except: [:basic]
  before_action :set_requirements_template, only: [:show, :edit, :update, :destroy, :toggle_active]
  before_action :check_DMPTemplate_editor_access, only: [:show, :edit, :update, :destroy]
  before_action :view_DMP_index_permission, only: [:index]

  # GET /requirements_templates
  # GET /requirements_templates.json
  def index
    if !user_role_in?(:dmp_admin)

      @requirements_templates = RequirementsTemplate.where.
                                any_of(institution_id: [current_user.institution.subtree_ids], visibility: :public)
    else
      @requirements_templates = RequirementsTemplate.all
    end

    @order_scope = params[:order_scope] || "last_modification_date"
    @scope = params[:scope] || "all_limited"
    @all_scope = params[:all_scope] || ""

    #to avoid sql injection 
    @direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

    
    case @scope
      when "all_limited"
        @requirements_templates = @requirements_templates
      when "active"
        @requirements_templates = @requirements_templates.active
      when "inactive"
        @requirements_templates = @requirements_templates.inactive
      when "public"
        @requirements_templates = @requirements_templates.public_visibility
      when "institutional"
        @requirements_templates = @requirements_templates.institutional_visibility
      when "your_inst_public"
        @requirements_templates = @requirements_templates.
                                    where(visibility: :public, institution_id: [current_user.institution.subtree_ids])
    end

    case @order_scope
      when "name"
        @requirements_templates = @requirements_templates.order('name'+ " " + @direction)
      when "institution"
        @requirements_templates = @requirements_templates.joins(:institution).
                                    order('institutions.full_name'+ " " + @direction)
      when "status"
        @requirements_templates = @requirements_templates.
                                  order('active'+ " " + (@direction == "asc" ? "desc" : "asc"))
      when "visibility"
        @requirements_templates = @requirements_templates.order('visibility'+ " " + @direction)
      when "creation_date"
        @requirements_templates = @requirements_templates.order('created_at'+ " " + @direction)
      when "last_modification_date"
        @requirements_templates = @requirements_templates.order('updated_at'+ " " + @direction)
      else
        @requirements_templates = @requirements_templates.order(name: :asc)
    end    

    case @all_scope
      when "all"
        @requirements_templates = @requirements_templates.page(params[:page]).per(9999)
      else
        @requirements_templates = @requirements_templates.page(params[:page]).per(10)
    end

    template_editors
    count
  end

  # GET /requirements_templates/1
  def show
    render 'edit'
  end

  # GET /requirements_templates/1/basic and basic_requirements_template_path
  # shows a basic template (as RTF for now)
  def basic
    @rt = RequirementsTemplate.find(params[:id])

    respond_to do |format|
      format.rtf {
        headers["Content-Disposition"] = "attachment; filename=\"" + sanitize_for_filename(@rt.name) + ".rtf\""
        render :layout => false,
               :content_type=> 'application/rtf'
               #:action => 'basic.rtf.erb',
      }
    end
  end

  # GET /requirements_templates/new
  def new
    @requirements_template = RequirementsTemplate.new
    # @requirements_template.tags.build
    @requirements_template.additional_informations.build
    @requirements_template.sample_plans.build
  end

  def template_information
    if user_role_in?(:dmp_admin)
      @requirements_templates = RequirementsTemplate.
                                  where(active: true).
                                  page(params[:page]).per(5)
    else
      @requirements_templates = RequirementsTemplate.
                                where(active: true).
                                any_of(visibility: :public, institution_id: [current_user.institution.root.subtree_ids]).
                                page(params[:page]).per(5)
    end
  end

  # GET /requirements_templates/1/edit
  def edit
    @sample_plans = @requirements_template.sample_plans
    @additional_informations = @requirements_template.additional_informations
    # @tags = @requirements_template.tags
  end

  # POST /requirements_templates
  # POST /requirements_templates.json
  def create
    @requirements_template = RequirementsTemplate.new(requirements_template_params)
    respond_to do |format|
      if params[:save_and_template_details]
        if @requirements_template.save
          format.html { redirect_to requirements_template_requirements_path(@requirements_template), notice: 'DMP Template was successfully created.' }
          format.json { head :no_content }
        else
          format.html { render action: 'new' }
          format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
        end
      else
        if @requirements_template.save
          format.html { redirect_to edit_requirements_template_path(@requirements_template), notice: 'DMP Template was successfully created.' }
          format.json { head :no_content }
        else
          format.html { render action: 'new' }
          format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /requirements_templates/1
  # PATCH/PUT /requirements_templates/1.json
  def update
    respond_to do |format|
      if params[:save_changes] || !params[:save_and_template_details]
        if @requirements_template.update(requirements_template_params)
          format.html { redirect_to edit_requirements_template_path(@requirements_template), notice: 'DMP Template was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
        end
      else
        if @requirements_template.update(requirements_template_params)
          format.html { redirect_to requirements_template_requirements_path(@requirements_template) }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /requirements_templates/1
  # DELETE /requirements_templates/1.json
  def destroy
    @requirements_template.destroy
    respond_to do |format|
      format.html { redirect_to requirements_templates_url }
      format.json { head :no_content }
    end
  end

  def copy_existing_template
    id = params[:requirements_template].to_i unless params[:requirements_template].blank?

    if user_role_in?(:dmp_admin)
      requirements_template = RequirementsTemplate.where(id: id).first
    else
      requirements_template = RequirementsTemplate.
                                where(id: id, institution_id: [current_user.institution.root.subtree_ids]).
                                first
    end

    @requirements_template = requirements_template.dup include: [:sample_plans, :additional_informations, :requirements], validate: false

    @requirements_template.name = "Copy of #{@requirements_template.name}"

    count = 1
    while RequirementsTemplate.where(name: @requirements_template.name).count > 0
      count += 1
      @requirements_template.name[/^Copy [0-9]* ?of/] = "Copy #{count} of"
    end

    respond_to do |format|
      if @requirements_template.save

        #now fix the ancestry to apply old order and structure to new
        o = requirements_template.requirements.order(:position).pluck(:id)
        n = @requirements_template.requirements.order(:position).pluck(:id)
        corr = Hash[o.zip(n)] #this creates a hash with old (keys) and new (values) for the copied requirements for updating ancestry column in new

        #now should be able to map any numbers in the ancestry column (example "274/279") into the new structure that was copied
        @requirements_template.requirements.each do |r|
          unless r.ancestry.nil?
            val = r.ancestry
            val = val.split("/").map{|i| corr[i.to_i]}.join("/")
            r.update_column(:ancestry, val ) #update new ancestry
          end
        end


        format.html { redirect_to edit_requirements_template_path(@requirements_template), notice: 'Requirements template was successfully created.' }
        format.json { render action: 'edit', status: :created, location: @requirements_template }
      else
        format.html { render action: 'new' }
        format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_active
    respond_to do |format|
      @requirements = @requirements_template.requirements
      if @requirements.empty?
        @msg =  "The DMP template \"#{@requirements_template.name}\" you are attempting to activate has no Requirements. A template must contain at least one Requirement before you may activate it."
        format.js { render 'activate_errors.js.erb' }
      else
        @requirements_template.toggle!(:active)
        format.js { render 'toggle_active.js.erb'}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_requirements_template
      @requirements_template = RequirementsTemplate.find(params[:id])
      @requirements_template.ensure_requirements_position unless @requirements_template.nil? #sets the positioning (order) of requirements if not set correctly
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def requirements_template_params
      params.require(:requirements_template).permit(:institution_id, :name, :active, :start_date, :end_date, :visibility, :review_type, tags_attributes: [:id, :requirements_template_id, :tag, :_destroy],
        additional_informations_attributes: [:id, :requirements_template_id, :url, :label, :_destroy], sample_plans_attributes: [:id, :requirements_template_id, :url, :label, :_destroy])
    end

    def template_editors
      @user_ids = Authorization.where(role_id: 3).pluck(:user_id) #All the DMP Template Editors

      case params[:scope]
        when "all_editors"
          @users = User.where(id: @user_ids).page(params[:page])
        else
          @users = User.where(id: @user_ids).page(params[:page]).per(3)
      end

      if !user_role_in?(:dmp_admin)
         @users = @users.where(id: @user_ids, institution_id: [current_user.institution.subtree_ids]).page(params[:page])
      end

    end

  def count
    if user_role_in?(:dmp_admin)
      @all = RequirementsTemplate.count
      @active = RequirementsTemplate.active.count
      @inactive = RequirementsTemplate.inactive.count
      @public = RequirementsTemplate.public_visibility.count
      @institutional = RequirementsTemplate.institutional_visibility.count
      @your_inst_public =  RequirementsTemplate.where(visibility: :public, 
                                institution_id: [current_user.institution.subtree_ids]).count

    
    else
      @all =  RequirementsTemplate.where.
                                any_of(institution_id: [current_user.institution.subtree_ids], visibility: :public).count
      @active = RequirementsTemplate.where.
                                any_of(institution_id: [current_user.institution.subtree_ids], visibility: :public).active.count
      @inactive = RequirementsTemplate.where.
                                any_of(institution_id: [current_user.institution.subtree_ids], visibility: :public).inactive.count
      @public = RequirementsTemplate.public_visibility.count
      @institutional = RequirementsTemplate.where(institution_id: [current_user.institution.subtree_ids]).institutional_visibility.count
      @your_inst_public =  RequirementsTemplate.where(visibility: :public, 
                                institution_id: [current_user.institution.subtree_ids]).count
    end

  end
end
