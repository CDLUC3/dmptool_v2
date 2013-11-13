class ResourceTemplatesController < ApplicationController
  require 'ability'

  before_filter :get_requirements_template
  before_action :set_resource_template, only: [:show, :edit, :update, :destroy, :toggle_active, :template_details]
  before_action :check_admin_access
  

  # GET /resource_templates
  # GET /resource_templates.json
  def index
    
    if safe_has_role?('dmp_administrator')
      @resource_templates = ResourceTemplate.page(params[:page])
    else   
      @resource_templates = ResourceTemplate.page(params[:page]).                      
                            where(institution_id: current_user.institution )
    end

    case params[:scope]
      when "active"
        @resource_templates = @resource_templates.where(active: true).per(10)
      when "inactive"
        @resource_templates = @resource_templates.where(active: false).per(10)
      else
        @resource_templates = @resource_templates.per(10)
    end
    resource_editors
  end


  # GET /resource_templates/1
  # GET /resource_templates/1.json
  def show
  end

  # GET /resource_templates/new
  def new
    @resource_template = ResourceTemplate.new
  end

  def template_information
    @resource_templates = ResourceTemplate.page.per(5)
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

  def copy_existing_template
    id = params[:resource_template].to_i unless params[:resource_template].blank?
    resource_template = ResourceTemplate.where(id: id).first
    @resource_template = resource_template.dup
    render action: "copy_existing_template"
  end

  def toggle_active
    @resource_template.toggle!(:active)
    respond_to do |format|
      format.js
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_template
      @resource_template = ResourceTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_template_params
      params.require(:resource_template).permit(:institution_id, :resource_template_id, :requirements_template_id, :name, :active, :mandatory_review, :contact_info, :contact_email, :review_type, :widget_url)
    end

    def get_requirements_template
      @requirements_templates = RequirementsTemplate.order(created_at: :asc).page(params[:page]).per(5)
    end

    def resource_editors

      @user_ids = Authorization.where(role_id: 2).pluck(:user_id) #All the Resources Editors

      if safe_has_role?('dmp_administrator')
        @users = User.where(id: @user_ids).order('created_at DESC').page(params[:page]).per(10)
      else
         
        @users = User.where(id: @user_ids, institution_id: current_user.institution).order('created_at DESC').page(params[:page]).per(10)
  
      end
      
    end

    

end
