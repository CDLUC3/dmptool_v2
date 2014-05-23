class ResourceContextsController < ApplicationController

  before_action :require_login
  before_action :check_customization_editor
  before_action :check_editor_for_this_customization, only: [:edit, :update]


  def index
    resource_customizations
  end


  # GET /resource_templates/new
  def new
    
    redirect_to :back and return if params[:requirements_template_id].blank?
    #institution_id, requirements_template_id, resource_id is NULL
    if user_role_in?(:dmp_admin) && params[:institution_id].blank?
      redirect_to({:action => :choose_institution, :requirements_template_id => params[:requirements_template_id]}) and return
    end
    @req_temp = RequirementsTemplate.find(params[:requirements_template_id])
    redirect_to :back and return if @req_temp.nil?
    @resource_context = ResourceContext.new
    @resource_context.requirements_template_id = @req_temp.id
    @resource_context.review_type = @req_temp.review_type

    #if it is for the template or for a a different institution
    if user_role_in?(:dmp_admin)
      if params[:institution_id] == "none"
        @resource_context.name = "#{@req_temp.name}"
      else
        that_inst = Institution.find(params[:institution_id])
        @resource_context.name = "#{@req_temp.name} for #{that_inst.name}"
      end
    else
      @resource_context.name = "#{@req_temp.name} for #{current_user.institution.name}"
    end

    #the institution_id should be nil if it's none, otherwise set it
    if user_role_in?(:dmp_admin)
      @resource_context.institution_id = ( params[:institution_id] == "none" ? nil : params[:institution_id])
    else
      @resource_context.institution_id = current_user.institution_id
    end
    if @resource_context.institution_id
      inst = Institution.find(@resource_context.institution_id)
      @resource_context.contact_email = inst.contact_email
      @resource_context.contact_info = inst.contact_info
    end

    existing = ResourceContext.where(institution_id:        @resource_context.institution_id).
                        where(requirements_template_id:     @resource_context.requirements_template_id).
                        where('requirement_id IS NULL').
                        where('resource_id IS NULL')
    if existing.length > 0
      redirect_to(edit_resource_context_path(existing.first.id) ) and return
    end

    make_institution_dropdown_list
  end


  # GET /resource_templates/edit
  def edit
    @resource_context = ResourceContext.find(params[:id])
    @req_temp = @resource_context.requirements_template
    make_institution_dropdown_list
    customization_resources_list
  end


  def create
    
    pare_to = ['institution_id', 'requirements_template_id', 'requirement_id', 'resource_id',
              'name', 'contact_info', 'contact_email', 'review_type']
    @resource_context = ResourceContext.new(params['resource_context'].selected_items(pare_to))
    make_institution_dropdown_list

    @req_temp = @resource_context.requirements_template
    message = @resource_context.changed ? 'Customization was successfully created.' : ''

    respond_to do |format|
      if @resource_context.save
        customization_resources_list
        go_to = (params[:after_save] == 'next_page' ? customization_requirement_path(@resource_context.id) :
                        edit_resource_context_path(@resource_context.id))
        format.html { redirect_to go_to, notice: message }
        format.json { head :no_content }
      else
        format.html { render 'new'}
        format.json { head :no_content }
        
      end
    end
    
  end


  def update

    @resource_context = ResourceContext.find(params[:id])
    pare_to = ['institution_id', 'requirements_template_id', 'requirement_id', 'resource_id',
               'name', 'contact_info', 'contact_email', 'review_type']
    

    to_save = params['resource_context'].selected_items(pare_to)
    message = @resource_context.changed ? 'Customization was successfully updated.' : ''

    make_institution_dropdown_list
    customization_resources_list
    @req_temp = @resource_context.requirements_template

    go_to = (params[:after_save] == 'next_page' ? customization_requirement_path(@resource_context.id) :
                  edit_resource_context_path(@resource_context.id) )
    respond_to do |format|
      if @resource_context.update(to_save)
        format.html { redirect_to go_to, notice: message }
        format.json { head :no_content }
      else
        format.html { render 'edit'}
        format.json { head :no_content }
        
      end
    end
    
  end


  def unlink_resource_from_template
    @customization_id = params[:customization_id]
    @resource_id = params[:resource_id]
    @template_id = params[:template_id]
    @custom_origin = params[:custom_origin]
    @tab_number = params[:tab_number]

    @institution_customization = ResourceContext.find(@customization_id).institution_id
    
    @resource_contexts = ResourceContext.
                            where(resource_id:              @resource_id, 
                                  requirements_template_id: @template_id,
                                  requirement_id:           nil,
                                  institution_id:           @institution_customization)
                                            
    @resource_contexts.each do |resource_context|
        resource_context.destroy
    end
    
    if @custom_origin == 'Overview'
      respond_to do |format|
        format.html { redirect_to edit_resource_context_path(@customization_id), 
                        notice: "The resource was successfully unlinked." }
      end
    else #details
      respond_to do |format|
        format.html { redirect_to customization_requirement_path(id: @customization_id, 
                      requirement_id:  @requirement_id,
                      anchor: @tab_number), 
                        notice: "The resource was successfully unlinked." }
      end
    end
  end


  def unlink_resource_from_requirement
    @customization_id = params[:customization_id]
    @resource_id = params[:resource_id]
    @template_id = params[:template_id]
    @custom_origin = params[:custom_origin]
    @tab_number = params[:tab_number]
    @requirement_id = params[:requirement_id]   

    @resource_contexts = ResourceContext.where(resource_id: @resource_id, 
                                                requirement_id: @requirement_id, 
                                                requirements_template_id: @template_id)

    @resource_contexts.each do |resource_context|
        resource_context.destroy
    end
    
    if @custom_origin == 'Overview'
      respond_to do |format|
        format.html { redirect_to edit_resource_context_path(@customization_id), 
                        notice: "The resource was successfully unlinked." }
      end
    else #details
      respond_to do |format|
        format.html { redirect_to customization_requirement_path(id: @customization_id, 
                      requirement_id:  @requirement_id,
                      anchor: @tab_number), 
                        notice: "The resource was successfully unlinked." }
      end
    end
  end


  def unlink_resource_from_customization

    @customization_id = params[:customization_id]
    @resource_id = params[:resource_id]
    @template_id = params[:template_id]
    @resource_context = ResourceContext.find(params[:customization_id])

    @resource_contexts = ResourceContext.where(resource_id: @resource_id, 
                                              requirements_template_id: @template_id,
                                              requirement_id: nil,
                                              institution_id: @resource_context.institution_id)

    @resource_contexts.each do |resource_context|
        resource_context.destroy
    end
    
    respond_to do |format|
      format.html { redirect_to edit_resource_context_path(@customization_id), 
                        notice: "The resource was successfully unlinked." }
    end
  end


  def unlink_institutional_resource
    @resource_context = ResourceContext.find(params[:resource_context_id])
    if @resource_context.destroy
      respond_to do |format|
        format.html { redirect_to institutions_path(anchor: 'tab_tab2'), 
                        notice: "The resource was successfully unlinked." }
      end
    else
      flash[:error] = "A problem prevented this resource to be unlinked."
      redirect_to institutions_path(anchor: 'tab_tab2')
    end
  end


  def destroy
    @resource_context = ResourceContext.find(params[:resource_context])
    
    @resource_contexts = ResourceContext.
                          where(institution_id: @resource_context.institution_id,
                                requirements_template_id: @resource_context.requirements_template_id)
    
    @resource_contexts.each do |resource_context|
        resource_context.destroy
    end

    respond_to do |format|
      format.html { redirect_to resource_contexts_url }
      format.json { head :no_content }
    end
  end


  def resource_customizations
    @resource_contexts = ResourceContext.template_level.no_resource_no_requirement.order_by_name

    unless user_role_in?(:dmp_admin)
      @resource_contexts = @resource_contexts.
                            where(institution_id: [current_user.institution.subtree_ids])
    end

    @scope = params[:scope]
    @order_scope = params[:order_scope]   

    case @order_scope
      when "Name"
        @resource_contexts = @resource_contexts.order_by_name
      when "Template"
        @resource_contexts = @resource_contexts.order_by_template_name
      when "Institution"
        @resource_contexts = @resource_contexts.order_by_institution_name
      when "Creation_Date"
        @resource_contexts = @resource_contexts.order_by_created_at
      when "Last_Modification_Date"
        @resource_contexts = @resource_contexts.order_by_updated_at 
      else
        @resource_contexts = @resource_contexts.order_by_name
    end

    case @scope
      when "all"
        @resource_contexts = @resource_contexts.page(params[:page]).per(1000)
      else
        @resource_contexts = @resource_contexts.page(params[:page]).per(10)
    end
    
  end


  def dmp_for_customization
    
    valid_buckets = nil
    
    if user_role_in?(:dmp_admin)
      req_temp = RequirementsTemplate.includes(:institution).where(active: true)
    
    elsif user_role_in?(:resource_editor, :institutional_admin)
      req_temp = RequirementsTemplate.
                        includes(:institution).
                        where(active: true).
                        any_of(visibility: :public, institution_id: [current_user.institution.subtree_ids])
    else
      @rt_tree = {}
      return
    end

    if !params[:q].blank?
      req_temp = req_temp.name_search_terms(params[:q])
    end

    if !params[:s].blank? && !params[:e].blank?
      req_temp = req_temp.letter_range(params[:s], params[:e])
    end

    process_requirements_template(req_temp)

    @back_to = resource_contexts_path
    @back_text = "Previous page"
    @submit_to = new_resource_context_path
    @submit_text = "Next page"
  end


  def customization_resources_list

    @customization = @resource_context
    @customization_institution = @resource_context.institution
    @template= @customization.requirements_template
    @customization_institution_name = (@customization_institution.nil? ? nil : @customization_institution.full_name)

    @template_name = (@customization.requirements_template.nil? ? nil : @customization.requirements_template.name)
      
    @resource_contexts = ResourceContext.includes(:resource).
                          per_template(@template).
                          no_requirement.
                          help_text_and_url_resources.
                          resource_level.
                          where(institution_id:
                                  (@customization_institution.nil? ? nil : [@customization_institution.subtree_ids])) 

    
    @all_institutions = "all Institutions"
                                             
  end


  def choose_institution
    make_institution_dropdown_list
  end


  def select_resource
    
    @origin_url = params[:origin_url]
    @custom_origin = params[:custom_origin]
    @tab = params[:tab]
    @tab_number = ''
    @resource_level = params[:resource_level]
    @template_id = params[:template_id]
    @customization_overview_id = params[:customization_overview_id]
    @requirement_id = params[:requirement_id]
    @customization = ResourceContext.find(@customization_overview_id)

    case @tab
      when "Guidance"
        @tab_number = 'tab_tab1'
      when "Links"
        @tab_number = 'tab_tab2'
      when "Example Response" 
        @tab_number = 'tab_tab3'
      when "Suggested Response"
        @tab_number = 'tab_tab3'
    end

    case @custom_origin
      when "Overview"
        @origin_path =  "#{edit_resource_context_path(@customization_overview_id)}"
      when "Details"
        @origin_path =  "#{customization_requirement_path(@customization_overview_id)}"
      else
        @origin_path =  "#{edit_resource_context_path(@customization_overview_id)}"
    end

    if user_role_in?(:dmp_admin)

      @resource_contexts = ResourceContext.joins(:resource).
                              where("resource_id IS NOT NULL").
                              where(institution_id:
                                  (@customization.institution.nil? ? nil : [@customization.institution.subtree_ids])).
                              group(:resource_id) 

      @any_resource =  ResourceContext.joins(:resource).
                              where("resource_id IS NOT NULL").
                              where(institution_id:
                                  (@customization.institution.nil? ? nil : [@customization.institution.subtree_ids]))

    else

      @resource_contexts = ResourceContext.joins(:resource).
                              where("resource_id IS NOT NULL").
                              where(institution_id: [current_user.institution.subtree_ids]).
                              group(:resource_id) 

      @any_resource =  ResourceContext.joins(:resource).
                              where("resource_id IS NOT NULL").
                              where(institution_id: [current_user.institution.subtree_ids])
    end

    if @resource_level != "requirement"
      @resource_contexts = @resource_contexts.help_text_and_url_resources
    end

    case @tab
      when "Guidance"
        @resource_contexts = @resource_contexts.help_text
        @any_resource = @any_resource.help_text
      when "Links"
        @resource_contexts = @resource_contexts.actionable_url
        @any_resource = @any_resource.actionable_url
      when "Suggested Response"
        @resource_contexts = @resource_contexts.suggested_response
        @any_resource = @any_resource.suggested_response
      when "Example Response"
        @resource_contexts = @resource_contexts.example_response
        @any_resource = @any_resource.example_response
      else
       @resource_contexts = @resource_contexts
    end
    

    if !params[:q].blank?
       @resource_contexts = @resource_contexts.search_terms(params[:q])
    end

    case params[:scope]
      when "Resource_id"
        @resource_contexts = @resource_contexts.order_by_resource_id
      when "Details"
        @resource_contexts = @resource_contexts.order_by_resource_label
      when "Type"
        @resource_contexts = @resource_contexts.order_by_resource_type
      when "Institution"
        @resource_contexts = @resource_contexts.order_by_institution_name
      when "Creation_Date"
        @resource_contexts = @resource_contexts.order_by_resource_created_at
      when "Last_Modification_Date"
        @resource_contexts = @resource_contexts.order_by_resource_updated_at
      else
       @resource_contexts = @resource_contexts.order_by_resource_label
    end

    @resource_contexts = @resource_contexts.page(params[:page]).per(20)

  end

  #@resources_count = @resource_contexts.count

end
