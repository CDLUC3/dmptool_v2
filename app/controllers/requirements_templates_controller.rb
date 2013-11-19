class RequirementsTemplatesController < ApplicationController
  before_action :set_requirements_template, only: [:show, :edit, :update, :destroy, :toggle_active]
  before_action :check_DMPTemplate_editor_access, only: [:show, :edit, :update, :destroy, :index]

  # GET /requirements_templates
  # GET /requirements_templates.json
  def index

    #if current_user.has_role?(Role::DMP_ADMIN)
      case params[:scope]
        when "all"
          @requirements_templates = RequirementsTemplate.all.page(params[:page])
        when "all_limited"
          @requirements_templates = RequirementsTemplate.all.page(params[:page])
        when "active"
          @requirements_templates = RequirementsTemplate.active.page(params[:page])
        when "inactive"
          @requirements_templates = RequirementsTemplate.inactive.page(params[:page])
        when "public"
          @requirements_templates = RequirementsTemplate.public_visibility.page(params[:page])
        when "institutional"
          @requirements_templates = RequirementsTemplate.institutional_visibility.page(params[:page])
        else
          @requirements_templates = RequirementsTemplate.order(created_at: :asc).page(params[:page])
      end


      if !current_user.has_role?(Role::DMP_ADMIN)
        @requirements_templates = @requirements_templates.where(institution_id: current_user.institution_id)
      end

      @requirements_templates = @requirements_templates.per(5)

      # case params[:scope]
      #   when "all"
      #     @requirements_templates = RequirementsTemplate.all.within_user_institution.page(params[:page])
      #   when "all_limited"
      #     @requirements_templates = RequirementsTemplate.all.within_user_institution.page(params[:page]).per(5)
      #   when "active"
      #     @requirements_templates = RequirementsTemplate.active.within_user_institution.page(params[:page]).per(5)
      #   when "inactive"
      #     @requirements_templates = RequirementsTemplate.inactive.within_user_institution.page(params[:page]).per(5)
      #   when "public"
      #     @requirements_templates = RequirementsTemplate.public_visibility.within_user_institution.page(params[:page]).per(5)
      #   when "institutional"
      #     @requirements_templates = RequirementsTemplate.institutional_visibility.within_user_institution.page(params[:page]).per(5)
      #   else
      #     @requirements_templates = RequirementsTemplate.order(created_at: :asc).within_user_institution.page(params[:page]).per(5)
      # end

    #else

      template_editors
  end

  # GET /requirements_templates/1
  # GET /requirements_templates/1.json
  def show
  end

  # GET /requirements_templates/new
  def new
    @requirements_template = RequirementsTemplate.new
    @requirements_template.tags.build
    @requirements_template.additional_informations.build
    @requirements_template.sample_plans.build
  end

  def template_information
    @requirements_templates = RequirementsTemplate.institutional_visibility.page.per(5)
  end

  # GET /requirements_templates/1/edit
  def edit
    @sample_plans = @requirements_template.sample_plans
    @additional_informations = @requirements_template.additional_informations
    @tags = @requirements_template.tags
  end

  # POST /requirements_templates
  # POST /requirements_templates.json
  def create
    @requirements_template = RequirementsTemplate.new(requirements_template_params)

    respond_to do |format|
      if @requirements_template.save
        format.html { redirect_to edit_requirements_template_path(@requirements_template), notice: 'Requirements template was successfully created.' }
        format.json { render action: 'edit', status: :created, location: @requirements_template }
      else
        format.html { render action: 'new' }
        format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requirements_templates/1
  # PATCH/PUT /requirements_templates/1.json
  def update
    respond_to do |format|
      if @requirements_template.update(requirements_template_params)
        format.html { redirect_to edit_requirements_template_path(@requirements_template), notice: 'Requirements template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
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
    requirements_template = RequirementsTemplate.where(id: id).first
    @requirements_template = requirements_template.dup include: [:resource_templates, :sample_plans, :additional_informations]
    render action: "copy_existing_template"
  end

  def toggle_active
    @requirements_template.toggle!(:active)
    respond_to do |format|
      format.js
    end
  end

  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_requirements_template
      @requirements_template = RequirementsTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def requirements_template_params
      params.require(:requirements_template).permit(:institution_id, :name, :active, :start_date, :end_date, :visibility, :version, :parent_id, :review_type, tags_attributes: [:id, :requirements_template_id, :tag, :_destroy],
        additional_informations_attributes: [:id, :requirements_template_id, :url, :label, :_destroy], sample_plans_attributes: [:id, :requirements_template_id, :url, :label, :_destroy])
    end

    def template_editors
      @user_ids = Authorization.where(role_id: 3).pluck(:user_id) #All the DMP Template Editors
      if safe_has_role?(Role::DMP_ADMIN)
        @users = User.where(id: @user_ids).order('created_at DESC').page(params[:page]).per(10)
      else
        @users = User.where(id: @user_ids, institution_id: current_user.institution).order('created_at DESC').page(params[:page]).per(10)
      end     
      #@role_id = Role.where(name: "requirements_editor").pluck(:id).first
    end

end
