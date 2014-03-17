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
    if current_user.has_role?(Role::DMP_ADMIN) && params[:institution_id].blank?
      redirect_to({:action => :choose_institution, :requirements_template_id => params[:requirements_template_id]}) and return
    end
    @req_temp = RequirementsTemplate.find(params[:requirements_template_id])
    redirect_to :back and return if @req_temp.nil?
    @resource_context = ResourceContext.new
    @resource_context.requirements_template_id = @req_temp.id

    #if it is for the template or for a a different institution
    if current_user.has_role?(Role::DMP_ADMIN)
      if params[:institution_id] == "none"
        @resource_context.name = "#{@req_temp.name}"
      else
        that_inst = Institution.find(params[:institution_id])
        @resource_context.name = "#{@req_temp.name} for #{that_inst.name}"
      end
      @required_fields_class = ''
    else
      @resource_context.name = "#{@req_temp.name} for #{current_user.institution.name}"
      @required_fields_class = ' required'
    end

    @resource_context.review_type = "formal_review"

    #the institution_id should be nil if it's none, otherwise set it
    if current_user.has_role?(Role::DMP_ADMIN)
      @resource_context.institution_id = ( params[:institution_id] == "none" ? nil : params[:institution_id])
    else
      @resource_context.institution_id = current_user.institution_id
    end
    @resource_context.contact_email = @req_temp.institution.contact_email
    @resource_context.contact_info = @req_temp.institution.contact_info

    existing = ResourceContext.where(institution_id:        @resource_context.institution_id).
                        where(requirements_template_id:     @resource_context.requirements_template_id).
                        where(requirement_id:               nil).
                        where(resource_id:                  nil)
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
        format.html { redirect_to go_to, notice: message}
        #format.json { render action: 'edit', status: :created, location: @resource_context }
      else
        format.html { render action: 'new' }
        #format.json { render json: @resource_context.errors, status: :unprocessable_entity }
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

    respond_to do |format|
      if @resource_context.update(to_save)
        go_to = (params[:after_save] == 'next_page' ? customization_requirement_path(@resource_context.id) :
                  edit_resource_context_path(@resource_context.id) )
        format.html { redirect_to go_to, notice: message }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @resource_context.errors, status: :unprocessable_entity }
      end
    end
  end


  def unlink_resource
    @customization_id = params[:customization_id]
    @resource_id = params[:resource_id]
    @template_id = params[:template_id]
    
    if params[:requirement_id] && !params[:template_id].nil? && params[:unlink_from_customization].nil?

      @requirement_id = params[:requirement_id]
      @resource_contexts = ResourceContext.where(resource_id: @resource_id, 
                                                requirement_id: @requirement_id, 
                                                requirements_template_id: @template_id)

    elsif params[:template_id]  && params[:unlink_from_customization].nil?
      @resource_contexts = ResourceContext.where(resource_id: @resource_id, 
                                                requirements_template_id: @template_id)
    
    elsif params[:unlink_from_customization] && !params[:template_id].nil? && !params[:resource_id].nil?

      @resource_context = ResourceContext.find(params[:customization_id])
      @resource_contexts = ResourceContext.where(resource_id: @resource_id, 
                                              requirements_template_id: @template_id,
                                              institution_id: @resource_context.institution_id)
    else

      respond_to do |format|
        format.html { redirect_to edit_resource_context_path(@customization_id), 
                        notice: "A problem prevented this resource to be unlinked." }
        format.json { head :no_content }
        return
      end

    end

    @resource_contexts.each do |resource_context|
        resource_context.destroy
    end
    
    respond_to do |format|
      format.html { redirect_to edit_resource_context_path(@customization_id) }
      format.json { head :no_content }
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
      respond_to do |format|
        format.html { redirect_to institutions_path(anchor: 'tab_tab2'), 
                        notice: "A problem prevented this resource to be unlinked." }
      end
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
    @resource_contexts = ResourceContext.template_level.no_resource_no_requirement.order_by_name.page(params[:page])

    unless safe_has_role?(Role::DMP_ADMIN)
      @resource_contexts = @resource_contexts.
                            where(institution_id: [current_user.institution.subtree_ids]).
                            order('name ASC')
    end

    case params[:scope]
      when "all"
        @resource_contexts.order_by_name 
      when "Name"
        @resource_contexts = @resource_contexts.order_by_name.per(10)
      when "Template"
        @resource_contexts = @resource_contexts.order_by_template_name.per(10)
      when "Institution"
        @resource_contexts = @resource_contexts.order_by_institution_name.per(10)
      when "Creation_Date"
        @resource_contexts = @resource_contexts.order_by_created_at.per(10)
      when "Last_Modification_Date"
        @resource_contexts = @resource_contexts.order_by_updated_at.per(10) 
      else
        @resource_contexts = @resource_contexts.order_by_name.per(10)
    end
    
  end

  def dmp_for_customization
    req_temp = RequirementsTemplate.includes(:institution)
    valid_buckets = nil
    if current_user.has_role?(Role::DMP_ADMIN)
      #all records
    elsif current_user.has_role?(Role::RESOURCE_EDITOR) || current_user.has_role?(Role::INSTITUTIONAL_ADMIN)
      req_temp = req_temp.where(institution_id: current_user.institution.subtree_ids)
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

    @template_name = @customization.requirements_template.name
      
    @resource_contexts = ResourceContext.includes(:resource).
                          per_template(@template).
                          no_requirement.
                          help_text_and_url_resources.
                          resource_level.
                          where(institution_id:
                                  (@customization_institution.nil? ? nil : [@customization_institution.subtree_ids]))                                                
  end


  def choose_institution
    make_institution_dropdown_list
  end


  def select_resource
   
    @tab = params[:tab]
    @resource_level = params[:resource_level]
    @template_id = params[:template_id]
    @customization_overview_id = params[:customization_overview_id]
    @requirement_id = params[:requirement_id]
    @customization = ResourceContext.find(@customization_overview_id)

    if safe_has_role?(Role::DMP_ADMIN) 

      @resource_contexts = ResourceContext.joins(:resource).
                              where("resource_id IS NOT NULL").
                              where(institution_id:
                                  (@customization.institution.nil? ? nil : [@customization.institution.subtree_ids])).
                              group(:resource_id) 
                              
    else

      @resource_contexts = ResourceContext.joins(:resource).
                              where("resource_id IS NOT NULL").
                              where(institution_id: [current_user.institution.subtree_ids]).
                              group(:resource_id)
                               
    end

    if @resource_level != "requirement"
      @resource_contexts = @resource_contexts.help_text_and_url_resources
    end

    case @tab
      when "Guidance"
        @resource_contexts = @resource_contexts.help_text
      when "Actionable Links"
        @resource_contexts = @resource_contexts.actionable_url
      when "Suggested Response"
        @resource_contexts = @resource_contexts.suggested_response
      when "Example Response"
        @resource_contexts = @resource_contexts.example_response
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
       @resource_contexts = @resource_contexts
    end

    @resource_contexts = @resource_contexts.page(params[:page]).per(20)

  end

end
