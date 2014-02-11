class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update]

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all
    # @resources = Resource.where(requirement_id: params[:requirement_id])
    # @requirements_template = @resource_template.requirements_template
    # requirement_ids = @requirements_template.requirements.pluck(:id)
    # @requirements = Requirement.where(id: requirement_ids)
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
  end

  # GET /resources/new
  def new
    @resource = Resource.new
    @current_institution = current_user.institution
  end

 
  #edit institutional resource
  def edit
    @resource = Resource.find(params[:id])
    @current_institution = current_user.institution
  end

  def edit_customization_resource
    @resource = Resource.find(params[:id])
     @customization_id = params[:customization_id]
  end

  def update_customization_resource
    @resource = Resource.find(params[:id])
    @customization_id = params[:customization_id]
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to edit_resource_context_path(@customization_id), notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_resource_context_path(@customization_id), notice: "A problem prevented this resource to be created. " }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  
  #create new institutional resource
  def create
    @resource = Resource.new(resource_params)
    @current_institution = current_user.institution
    respond_to do |format|
      if @resource.save 
        @resource_id = @resource.id
        @resource_context = ResourceContext.new(resource_id: @resource_id, institution_id: @current_institution.id)
        if @resource_context.save
          format.html { redirect_to institutions_path(anchor: 'tab_tab2'), notice: "Resource was successfully created." }
        end
         
      else
        format.html { redirect_to institutions_path(anchor: 'tab_tab2'), notice: "A problem prevented this resource to be created. " }
      end
    end
  end

  #update institutional resource
  def update
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to institutions_path(anchor: 'tab_tab2'), notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to institutions_path(anchor: 'tab_tab2'), notice: "A problem prevented this resource to be created. " }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource_id = params[:resource_id]
    @resource = Resource.find(@resource_id)
    @customization_ids = ResourceContext.where(resource_id: @resource_id).pluck(:id)
    if @resource.destroy
      if @customization_ids
        ResourceContext.destroy(@customization_ids)
      end
      respond_to do |format|
        format.html { redirect_to edit_resource_context_path(params[:customization_overview_id]), notice: 'Resource was successfully eliminated.' }
        format.json { head :no_content }
      end
    else
      format.html { redirect_to edit_resource_context_path(params[:customization_overview_id]), notice: "A problem prevented this resource to be eliminated. " }
    end
  end

  def new_customization_resource
    @template_id = params[:template_id]
    @template_name = RequirementsTemplate.find(@template_id).name
    @resource = Resource.new
    @current_institution_id = params[:institution_id]
    @customization_overview_id = params[:customization_overview_id]
  end

  def create_customization_resource
    @template_id = params[:template_id]
    @resource = Resource.new(resource_params)
    @current_institution_id = params[:current_institution_id]
    @customization_overview_id = params[:customization_overview_id]
    respond_to do |format|
      if @resource.save 
        @resource_id = @resource.id
        @resource_context = ResourceContext.new(resource_id: @resource_id, institution_id: @current_institution_id, 
                                                requirements_template_id: @template_id)
        if @resource_context.save
          format.html { redirect_to edit_resource_context_path(@customization_overview_id), notice: "Resource was successfully created." }
        end
         
      else
        format.html { redirect_to edit_resource_context_path(@customization_overview_id), notice: "A problem prevented this resource to be created. " }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:resource_type, :value, :label, :text)
    end
end
