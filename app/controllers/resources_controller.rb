class ResourcesController < ApplicationController
  before_filter :get_resource_template
  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  

  # GET /resources
  # GET /resources.json
  def index
    @resource = @resource_template.resources.build
    @resources = @resource_template.resources
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
  end

  # GET /resources/new
  def new
    @resource = @resource_template.resources.build(:parent_id => params[:parent_id])
    @resources = @resource_template.resources
    render 'index'
  end

  # GET /resources/1/edit
  def edit
    @resources = @resource_template.resources
    render 'index'
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = @resource_template.resources.build(resource_params)
    @resources = @resource_template.resources
    respond_to do |format|
      if @resource.save
        format.html { redirect_to resource_template_resources_path(@resource_template), notice: 'Resource was successfully created.' }
        format.json { render action: 'show', status: :created, location: @resource }
      else
        format.html { render action: 'index' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    @resources = @resource_template.resources
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to  resource_template_resources_path(@resource_template), notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'index' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resources = @resource_template.resources
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = @resource_template.resources.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:resource_type, :value, :label, :requirement_id, :resource_template_id)
    end

    def get_resource_template
      @resource_template =  ResourceTemplate.find(params[:resource_template_id])
    end
end
