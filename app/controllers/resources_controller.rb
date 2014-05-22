 class ResourcesController < ApplicationController

  before_action :require_login, only: [:show]
  before_action :set_resource, only: [:show, :edit, :update]

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all
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
    @tab_number = params[:tab_number] || ''
    @custom_origin = params[:custom_origin]

    @resource_templates_id = ResourceContext.where(resource_id: @resource.id).pluck(:requirements_template_id)

    @resource_contexts_templates = ResourceContext.
                                    where(resource_id: @resource.id, requirement_id: nil).
                                      template_level#template_id is not nil

    @templates_count = ResourceContext.where(resource_id: @resource.id, requirement_id: nil).
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
    
    @resource_type = params[:resource][:resource_type]
    @value = params[:resource][:value]
    @tab = params[:tab]
    @tab_number = params[:tab_number]
    @custom_origin = params[:custom_origin]
    @resource = Resource.find(params[:id])
    @customization_id = params[:customization_id]
    @resource_level = params[:resource_level]
    @requirement_id = params[:requirement_id]
    @template_id = params[:template_id]

    if @resource_level == 'requirement' #customization details


      if (  (@resource_type == "actionable_url") &&  (!is_valid_url?(@value))  )
        flash[:error] = "The url: #{@value} is a not valid url."  
        redirect_to edit_customization_resource_path(id: @resource.id,
                                               customization_id: @customization_id,
                                               custom_origin: @custom_origin)         
        return
      end

      respond_to do |format|
        if @resource.update(resource_params)
          format.html { redirect_to customization_requirement_path(id: @customization_id, 
                      requirement_id:  @requirement_id, 
                      anchor: @tab_number),
                      notice: 'Resource was successfully updated.'  }
          format.json { head :no_content }
        else
          format.html { render 'edit_customization_resource'}
          format.json { head :no_content }    
        end
      end
      
    else #customization overview

      if (  (@resource_type == "actionable_url") &&  (!is_valid_url?(@value))  )
        flash[:error] = "The url: #{@value} is a not valid url."  
        redirect_to edit_customization_resource_path(id: @resource.id,
                                               customization_id: @customization_id,
                                               custom_origin: @custom_origin)         
        return
      end

      respond_to do |format|
        if @resource.update(resource_params)
          format.html { redirect_to edit_resource_context_path(@customization_id),
                      notice: 'Resource was successfully updated.'  }
          format.json { head :no_content }
        else
          format.html { render 'edit_customization_resource'}
          format.json { head :no_content }    
        end
      end
      
    end

  end
 
#create institutional resource
  def create
    @tab_number = (params[:tab_number].blank? ? 'tab_tab2' : params[:tab_number] )
    @resource = Resource.new(resource_params)
    @current_institution = current_user.institution
    respond_to do |format|
      if @resource.save
        @resource_context = ResourceContext.new(resource_id: @resource.id, institution_id: @current_institution.id)
        if @resource_context.save
          format.html { redirect_to params[:origin_url] + "##{@tab_number}", notice: "Resource was successfully created."}
          format.json { head :no_content }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  #update institutional resource
  def update
    @current_institution = current_user.institution
    @resource = Resource.find(params[:id])
    @tab_number = (params[:tab_number].blank? ? 'tab_tab2' : params[:tab_number])
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to params[:origin_url] + "##{@tab_number}", notice: 'Resource was successfully updated.'}
        format.json { head :no_content }
      else
        format.html { render 'edit'}
        format.json { head :no_content }
        
      end
    end
  end

  # DELETE /resources/1
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
      
        #if @customization_id #customization resource
        if !request[:origin_url].blank?
          
            redirect_to request[:origin_url] + "##{@tab_number}",
                      notice: 'Resource was successfully eliminated.'
          
        elsif @custom_origin == "Overview" #customization resource
          
            redirect_to edit_resource_context_path(params[:customization_overview_id]), 
              notice: 'Resource was successfully eliminated.' 
          
        elsif @custom_origin == "Details"
          
          flash[:notice] = 'Resource was successfully eliminated.'
          redirect_to customization_requirement_path(id: @customization_id, 
                      requirement_id:  @requirement_id), 
                      anchor: '#'+@tab_number 
          
        elsif !@customization_id #institutional resource
          
            redirect_to institutions_path(anchor: 'tab_tab2'), 
              notice: 'Resource was successfully eliminated.' 
          
        else 
           
            redirect_to edit_resource_context_path(params[:customization_overview_id]), 
              notice: 'Resource was successfully eliminated.' 
          
        end
      
    else
      flash[:error] = "A problem prevented this resource to be eliminated."
      redirect_to edit_resource_context_path(params[:customization_overview_id])
    end
  end


  def new_customization_resource

    @tab = params[:tab]
    @custom_origin = params[:custom_origin]
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
      when "Links"
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
   
    @resource_type = params[:resource][:resource_type]
    @value = params[:resource][:value]
    @tab = params[:tab]
    @custom_origin = params[:custom_origin]
    @tab_number = params[:tab_number]
    @requirement_id = params[:requirement_id]
    @resource_level = params[:resource_level]
    @template_id = params[:template_id]
    @template_name = RequirementsTemplate.find(@template_id).name
    @customization_overview_id = params[:customization_overview_id]
    @customization_overview = ResourceContext.find(@customization_overview_id)

    
    if (  (@resource_type == "actionable_url") &&  (!is_valid_url?(@value))  )
  
      flash[:error] = "The url: #{@value} is a not valid url."
      
      redirect_to new_customization_resource_path(
                custom_origin:  @custom_origin,
                template_id: @template_id,
                customization_overview_id: @customization_overview_id,
                resource_level: @resource_level,
                tab:            @tab,
                requirement_id: @requirement_id,
                tab_number:     @tab_number) 
      return
    end
    

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
              format.html { redirect_to customization_requirement_path(id: @customization_overview_id, 
                  requirement_id:  @requirement_id,
                  anchor: @tab_number), 
                  notice: "Resource was successfully created."}
            else
              format.html { render 'new_customization_resource'}
            end

          else
            format.html { render 'new_customization_resource'}
          end
        end

      else #customization resource
          
          @resource = Resource.new(resource_params)
            
         
          respond_to do |format|
            if @resource.save
              @resource_id = @resource.id
              @resource_context = ResourceContext.new(resource_id: @resource_id, 
                                                      institution_id: @current_institution_id, 
                                                      requirements_template_id: @template_id)
              if @resource_context.save
                format.html { redirect_to edit_resource_context_path(@customization_overview_id), 
                                          notice: "Resource was successfully created."}
              else
                format.html { render 'new_customization_resource'}
              end

            else
              format.html { render 'new_customization_resource'}
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
         
    if @custom_origin == "Details" 

      if requirement_customization_present?(@resource_id, @template_id, @current_institution_id, @requirement_id)  
        flash[:error] = "The resource you selected is already in your context."   
        redirect_to customization_requirement_path(id: @customization_overview_id, 
          requirement_id:  @requirement_id,
          anchor: @tab_number)
        return
      else 
        @resource_context = ResourceContext.new(resource_id: @resource_id, 
                                                institution_id: @current_institution_id, 
                                                requirements_template_id: @template_id,
                                                requirement_id: @requirement_id) 
        if @resource_context.save
          redirect_to customization_requirement_path(id: @customization_overview_id, 
                                                    requirement_id:  @requirement_id,
                                                    anchor: @tab_number), 
                                                    notice: "Resource was successfully added."        
        else
          flash[:error] = "A problem prevented this resource to be added."
          redirect_to customization_requirement_path(id: @customization_overview_id, 
                                                    requirement_id:  @requirement_id,
                                                    anchor: @tab_number)
        end
      end 

    else #@custom_origin == "Overview"
 
      if template_customization_present?(@resource_id, @template_id, @current_institution_id)  
        flash[:error] = "The resource you selected is already in your context."
        redirect_to edit_resource_context_path(@customization_overview_id)        
      else
        @resource_context = ResourceContext.new(resource_id: @resource_id, 
                                                institution_id: @current_institution_id, 
                                                requirements_template_id: @template_id)  
        if @resource_context.save
          redirect_to edit_resource_context_path(@customization_overview_id), notice: "Resource was successfully added."        
        else
          flash[:error] = "A problem prevented this resource to be added."
          redirect_to edit_resource_context_path(@customization_overview_id) 
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

    def is_valid_url?(str)
      begin
        uri = URI.parse(str)
        str.start_with?('mailto')  || uri.kind_of?(URI::HTTP)
      rescue URI::InvalidURIError
        false
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:resource_type, :value, :label, :text)
    end



end