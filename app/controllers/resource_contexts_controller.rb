class ResourceContextsController < ApplicationController

  def index
    resource_customizations
  end

  # GET /resource_templates/new
  def new
    redirect_to :back and return if params[:requirements_template_id].blank?
    @req_temp = RequirementsTemplate.find(params[:requirements_template_id])
    redirect_to :back and return if @req_temp.nil?
    @resource_context = ResourceContext.new
    @resource_context.requirements_template_id = @req_temp.id
    @resource_context.name = "#{@req_temp.name} for #{current_user.institution.name}"
    @resource_context.review_type = "formal_review"
    @resource_context.institution_id = current_user.institution.id
    @resource_context.contact_email = @req_temp.institution.contact_email
    @resource_context.contact_info = @req_temp.institution.contact_info

    make_institution_dropdown_list
  end

  # GET /resource_templates/edit
  def edit
    @resource_context = ResourceContext.find(params[:id])
    @req_temp = @resource_context.requirements_template

    make_institution_dropdown_list
  end

  def create
    pare_to = ['institution_id', 'requirements_template_id', 'requirement_id', 'resource_id',
              'name', 'contact_info', 'contact_email', 'review_type']
    to_save = pare_to.inject({}){|result, key| result[key] = params['resource_context'][key];result}
    @resource_context = ResourceContext.new(to_save)
    respond_to do |format|
      if @resource_context.save
        format.html { redirect_to customization_details_path(@resource_context.id), notice: 'Customization was successfully created.' }
        #format.json { render action: 'edit', status: :created, location: @resource_context }
      else
        make_institution_dropdown_list
        @req_temp = @resource_context.requirements_template
        format.html { render action: 'new' }
        #format.json { render json: @resource_context.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @resource_context.update(resource_context_params)
        format.html { redirect_to edit_resource_context_path(@resource_context), notice: 'Resource context was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @resource_context.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @resource_context.destroy
    respond_to do |format|
      format.html { redirect_to resource_contexts_url }
      format.json { head :no_content }
    end
  end
 

  def resource_customizations
    @resource_contexts = ResourceContext.template_level.institutional_level.no_resource_no_requirement.page(params[:page])
    case params[:scope]
      when "all"
        @resource_contexts 
    
      else
        @resource_contexts = @resource_contexts.per(5)
    end

    unless safe_has_role?(Role::DMP_ADMIN)
      @resource_contexts = @resource_contexts.
                            where(institution_id: [current_user.institution.subtree_ids])
    end
  end

  def dmp_for_customization
    select_requirements_template
    @back_to = resource_contexts_path
    @back_text = "Previous page"
    @submit_to = new_resource_context_path
    @submit_text = "Next page"
  end
end
