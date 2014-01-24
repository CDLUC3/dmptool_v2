class ResourceTemplatesController < ApplicationController

  before_filter :get_requirements_template
  before_action :set_resource_template, only: [:show, :edit, :update, :destroy, :resources ]
  before_action :check_resource_editor_access, only: [:show, :edit, :update, :destroy, :template_details, :index]

  # GET /resource_templates
  # GET /resource_templates.json
  def index
    resource_customizations

    resources
  end


  # GET /resource_templates/1
  # GET /resource_templates/1.json
  def show
  end

  # GET /resource_templates/new
  def new
    @resource_template = ResourceTemplate.new
  end

  # GET /resource_templates/1/edit
  def edit
  end

  # POST /resource_templates
  # POST /resource_templates.json
  def create
    @resource_template = ResourceTemplate.new(resource_template_params)
    respond_to do |format|
      if @resource_template.save
        format.html { redirect_to edit_resource_template_path(@resource_template), notice: 'Resource template was successfully created.' }
        format.json { render action: 'edit', status: :created, location: @resource_template }
      else
        format.html { render action: 'new' }
        format.json { render json: @resource_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resource_templates/1
  # PATCH/PUT /resource_templates/1.json
  def update
    respond_to do |format|
      if @resource_template.update(resource_template_params)
        format.html { redirect_to edit_resource_template_path(@resource_template), notice: 'Resource template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @resource_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_templates/1
  # DELETE /resource_templates/1.json
  def destroy
    @resource_template.destroy
    respond_to do |format|
      format.html { redirect_to resource_templates_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_template
      @resource_template = ResourceTemplate.find(params[:id])
    end

    def resource_template_params
      params.require(:resource_template).permit(:institution_id, :resource_template_id, :requirements_template_id, :name, :contact_info, :contact_email, :review_type, :widget_url)
    end

    def get_requirements_template
      if !safe_has_role?(Role::DMP_ADMIN)
        unless params[:show_all] == 'true'
          @requirements_templates = RequirementsTemplate.where.any_of(institution_id: [current_user.institution.subtree_ids], visibility: :public).active.order(created_at: :asc).page(params[:page]).per(5)
        else
          @requirements_templates = RequirementsTemplate.where.any_of(institution_id: [current_user.institution.subtree_ids], visibility: :public).active.order(created_at: :asc).page(params[:page])
        end
      else
        unless params[:show_all] == 'true'
          @requirements_templates = RequirementsTemplate.active.order(created_at: :asc).page(params[:page]).per(5)
        else
          @requirements_templates = RequirementsTemplate.active.order(created_at: :asc).page(params[:page])
        end
      end
    end

    def resource_customizations
      case params[:scope]
        when "all"
          @resource_templates = ResourceTemplate.page(params[:page])
        when "all_limited"
          @resource_templates = ResourceTemplate.page(params[:page]).per(5)
        else
          @resource_templates = ResourceTemplate.page(params[:page]).per(5)
      end

      if !safe_has_role?(Role::DMP_ADMIN)
        @resource_templates = @resource_templates.
                              where(institution_id: [current_user.institution.subtree_ids])
      end
    end

    def resources #TO BE COMPLETED
      @title = "Resources Available at " + current_user.institution.full_name
      @new_resources = ResourceContext.where(institution_id: [current_user.institution.subtree_ids],
                                            requirement_id: nil, resource_template_id: nil,
                                            requirements_template_id: nil)
    end

    def resource_editors
      @user_ids = Authorization.where(role_id: 2).pluck(:user_id) #All the Resources Editors
      if safe_has_role?(Role::DMP_ADMIN)
        @users = User.where(id: @user_ids).order('created_at DESC').page(params[:page]).per(10)
      else
        @users = User.where(id: @user_ids, institution_id: [current_user.institution.subtree_ids]).order('created_at DESC').page(params[:page]).per(10)
      end
      @users = @users.order(first_name: :asc, last_name: :asc).page(params[:editor_page]).per(5)
    end
end
