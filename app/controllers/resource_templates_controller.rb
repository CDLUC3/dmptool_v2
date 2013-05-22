class ResourceTemplatesController < ApplicationController
  before_action :set_resource_template, only: [:show, :edit, :update, :destroy]

  # GET /resource_templates
  # GET /resource_templates.json
  def index
    @resource_templates = ResourceTemplate.all
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
        format.html { redirect_to @resource_template, notice: 'Resource template was successfully created.' }
        format.json { render action: 'show', status: :created, location: @resource_template }
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
        format.html { redirect_to @resource_template, notice: 'Resource template was successfully updated.' }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_template_params
      params.require(:resource_template).permit(:institution_id, :requirements_template_id, :name, :active, :mandatory_review, :widget_url)
    end
end
