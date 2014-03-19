 class ResourcesController < ApplicationController

  before_action :require_login, only: [:show]
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
    @resource_level = params[:resource_level]
    @customization_id = params[:customization_id]
    @template_id = params[:template_id]
    @requirement_id = params[:requirement_id]
    @tab = params[:tab]
    @tab_number = params[:tab_number]
    @custom_origin = params[:custom_origin]

    @resource_templates_id = ResourceContext.where(resource_id: @resource.id).pluck(:requirements_template_id)

    @resource_contexts_templates = ResourceContext.where(resource_id: @resource.id).
                                        template_level. #template_id is not nil
                                        includes(:requirements_template).
                                        group(:requirements_template_id)

    @templates_count = ResourceContext.where(resource_id: @resource.id).
                                        template_level. #template_id is not nil
                                        select(:requirements_template_id).count

    @any_templates = ( @templates_count > 0 )

    @resource_contexts_requirements = ResourceContext.where(resource_id: @resource.id).
                                        requirement_level. #requirement_id is not nil
                                        includes(:requirement).
                                        includes(:requirements_template).
                                        group(:requirement_id)

    @requirements_count = ResourceContext.where(resource_id: @resource.id).
                                        requirement_level. #requirement_id is not nil
                                        select(:requirement_id).count


    @any_requirements = ( @requirements_count > 0 )

  end

  def update_customization_resource
    
    @tab = params[:tab]
    @tab_number = params[:tab_number]
    @custom_origin = params[:custom_origin]
    @resource = Resource.find(params[:id])
    @customization_id = params[:customization_id]
    @resource_level = params[:resource_level]
    @requirement_id = params[:requirement_id]

    if @resource_level == 'requirement' #customization details

      respond_to do |format|
        if @resource.update(resource_params)
          
          format.html { redirect_to customization_requirement_path(id: @customization_id, 
                        requirement_id:  @requirement_id, 
                        anchor: @tab_number),
                        
                        notice: 'Resource was successfully updated.' }
        else
          format.html { redirect_to customization_requirement_path(id: @customization_id, 
                        requirement_id:  @requirement_id,
                        anchor: @tab_number),
                        notice: "A problem prevented this resource to be updated. " }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end

    else #customization overview

      respond_to do |format|
        if @resource.update(resource_params)        
          format.html { redirect_to edit_resource_context_path(@customization_id),
                        notice: 'Resource was successfully updated.' }
        else
          format.html { redirect_to edit_resource_context_path(@customization_id), 
                          notice: "A problem prevented this resource to be updated. " }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
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
      @tab_number = (params[:tab_number].blank? ? 'tab_tab2' : params[:tab_number])
      if @resource.update(resource_params)
        format.html { redirect_to params[:origin_url] + "#" + @tab_number, notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to params[:origin_url] + "#" + @tab_number, notice: "A problem prevented this resource to be updated. " }
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
    @customization_id = params[:customization_overview_id]
    @custom_origin = params[:custom_origin]
    @tab_number = params[:tab_number]
    @requirement_id = params[:requirement_id]

    if @resource.destroy
      if @customization_ids
        ResourceContext.destroy(@customization_ids)
      end
      respond_to do |format|
        #if @customization_id #customization resource
        if @custom_origin == "Overview" #customization resource
          format.html { 
            redirect_to edit_resource_context_path(params[:customization_overview_id]), 
              notice: 'Resource was successfully eliminated.' 
          }
        elsif @custom_origin == "Details"
          format.html { 
            redirect_to customization_requirement_path(id: @customization_id, 
                      requirement_id:  @requirement_id), 
                      anchor: '#'+@tab_number,
                      notice: "A problem prevented this resource to be created. " 
          }
        elsif !@customization_id #institutional resource
          format.html { 
            redirect_to institutions_path(anchor: 'tab_tab2'), 
              notice: 'Resource was successfully eliminated.' 
          }
        else 
          format.html { 
            redirect_to edit_resource_context_path(params[:customization_overview_id]), 
              notice: 'Resource was successfully eliminated.' 
          }
        end
      end
    else
      format.html { redirect_to edit_resource_context_path(params[:customization_overview_id]), notice: "A problem prevented this resource to be eliminated. " }
    end
  end


  def new_customization_resource

    @tab = params[:tab]
    @tab_number = params[:tab_number]
    @requirement_id = params[:requirement_id]
    @resource_level = params[:resource_level]
    @template_id = params[:template_id]
    @customization_overview_id = params[:customization_overview_id]
    @template_name = RequirementsTemplate.find(@template_id).name
    @resource = Resource.new

    @customization_overview = ResourceContext.find(@customization_overview_id)
    @current_institution_id = nil

    if user_role_in?(:dmp_admin)
      @current_institution_id = @customization_overview.institution_id
    else 
      @current_institution_id = current_user.institution.id
    end
   
    case @tab
      when "Guidance"
        @selected = "help_text"
      when "Actionable Links"
        @selected = "actionable_url"
      when "Suggested Response"
        @selected = "suggested_response"
      when "Example Response"
        @selected = "example_response"
      else
       @selected = "help_text"
    end
      

  end


  def create_customization_resource
    
    @tab = params[:tab]
    @custom_origin = params[:custom_origin]
    @tab_number = params[:tab_number]
    @requirement_id = params[:requirement_id]
    @resource_level = params[:resource_level]
    @template_id = params[:template_id]
    @customization_overview_id = params[:customization_overview_id]
    @customization_overview = ResourceContext.find(@customization_overview_id)

    if user_role_in?(:dmp_admin)
      @current_institution_id = @customization_overview.institution_id
    else 
      @current_institution_id = current_user.institution.id
    end

    case params[:resource_level]
      
      when "requirement" #origin == Details
    
        @resource = Resource.new(resource_params)

        respond_to do |format|
          if @resource.save 
            @resource_id = @resource.id
            @resource_context = ResourceContext.new(resource_id: @resource_id, 
                                      institution_id: @current_institution_id, 
                                      requirements_template_id: @template_id,
                                      requirement_id:  @requirement_id)
            if @resource_context.save
              format.html { 
                redirect_to customization_requirement_path(id: @customization_overview_id, 
                      requirement_id:  @requirement_id,
                      anchor: @tab_number), 
                      notice: "Resource was successfully created." }
            end
             
          else
            format.html { 
              redirect_to customization_requirement_path(id: @customization_overview_id, 
                      requirement_id:  @requirement_id,
                      anchor: @tab_number), 
                      notice: "A problem prevented this resource to be created. " }
          end
        end

      else #customization resource
          
          @resource = Resource.new(resource_params)
            
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
  end


  def copy_selected_customization_resource

    @tab = params[:tab]
    @custom_origin = params[:custom_origin]
    @tab_number = params[:tab_number]
    @requirement_id = params[:requirement_id]
    @resource_level = params[:resource_level]
    @resource_id = params[:resource]
    @template_id = params[:template_id]
    @resource = Resource.find(@resource_id)
    @customization_overview_id = params[:customization_overview_id]
    @customization_overview = ResourceContext.find(@customization_overview_id)  

    if user_role_in?(:dmp_admin)
      @current_institution_id = @customization_overview.institution_id
    else 
      @current_institution_id = current_user.institution.id
    end
         
    #if params[:resource_level] == "requirement" #details 
    if @custom_origin == "Details" 

      if requirement_customization_present?(@resource_id, @template_id, @current_institution_id, @requirement_id)     
        respond_to do |format|
          format.html { 
              redirect_to customization_requirement_path(id: @customization_overview_id, 
                requirement_id:  @requirement_id,
                anchor: @tab_number), 
              notice: "The resource you selected is already in your context." }
        end
        return
      else
     
        @resource_context = ResourceContext.new(resource_id: @resource_id, 
                                                institution_id: @current_institution_id, 
                                                requirements_template_id: @template_id,
                                                requirement_id: @requirement_id) 
        respond_to do |format| 
          if @resource_context.save
            format.html { redirect_to customization_requirement_path(id: @customization_overview_id, 
              requirement_id:  @requirement_id,
                      anchor: @tab_number), 
                notice: "Resource was successfully added." }        
          else
            format.html { redirect_to customization_requirement_path(id: @customization_overview_id, 
              requirement_id:  @requirement_id,
                      anchor: @tab_number), 
                notice: "A problem prevented this resource to be added. " }
          end
        end    
 
      end #if params[:resource_level] == "requirement" 


    elsif  @custom_origin == "Overview"
 
      if template_customization_present?(@resource_id, @template_id, @current_institution_id)
        
        respond_to do |format|
                format.html { redirect_to edit_resource_context_path(@customization_overview_id), 
                          notice: "The resource you selected is already in your context." }
        end
              
      else
     
        @resource_context = ResourceContext.new(resource_id: @resource_id, 
                                                institution_id: @current_institution_id, 
                                                requirements_template_id: @template_id) 
        respond_to do |format| 
              if @resource_context.save
                format.html { redirect_to edit_resource_context_path(@customization_overview_id), 
                              notice: "Resource was successfully added." }        
              else
                format.html { redirect_to edit_resource_context_path(@customization_overview_id), 
                              notice: "A problem prevented this resource to be added. " }
              end
        end    
      end 

    else
      if template_customization_present?(@resource_id, @template_id, @current_institution_id)
        
        respond_to do |format|
                format.html { redirect_to edit_resource_context_path(@customization_overview_id), 
                          notice: "The resource you selected is already in your context." }
        end
              
      else  
        @resource_context = ResourceContext.new(resource_id: @resource_id, 
                                                institution_id: @current_institution_id, 
                                                requirements_template_id: @template_id) 
        respond_to do |format| 
              if @resource_context.save
                format.html { redirect_to edit_resource_context_path(@customization_overview_id), 
                              notice: "Resource was successfully added." }        
              else
                format.html { redirect_to edit_resource_context_path(@customization_overview_id), 
                              notice: "A problem prevented this resource to be added. " }
              end
        end    
      end 
    end
        
  end


  def template_customization_present?(resource_id, template_id, current_institution_id)
    ResourceContext.where(resource_id: resource_id, 
                          requirements_template_id: template_id, 
                          institution_id: current_institution_id,
                          requirement_id: nil).
                    pluck(:id).count > 0 
  end

  def requirement_customization_present?(resource_id, template_id, current_institution_id, requirement_id)
    ResourceContext.where(resource_id: resource_id, 
                          requirements_template_id: template_id, 
                          institution_id: current_institution_id,
                          requirement_id: requirement_id).
                    pluck(:id).count > 0 
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