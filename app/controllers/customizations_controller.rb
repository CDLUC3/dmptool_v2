class CustomizationsController < ApplicationController

  # information to display the repetitive tabs
  TABS = [  {name: 'Guidance', partial: 'guidance_item', scope: :guidance},
            {name: 'Actionable Links', partial: 'actionable_url_item', scope: :actionable_url},
            {name: 'Suggested Response', partial: 'guidance_item', scope: :suggested_response},
            {name: 'Example Response', partial: 'guidance_item', scope: :example_response }
          ]  #right now all but links are displayed wiht the guidance partial since they're the same

  def show
    # :id is customization id and :requirement_id
    @customization = ResourceContext.find(params[:id])
    redirect_to(resource_contexts_path, :notice => "This isn't a valid customization") and return unless @customization.resource_id.blank?
    begin
      @requirements_template = @customization.requirements_template
      @requirements = @requirements_template.requirements
      if params[:requirement_id].blank?
        params[:requirement_id] = @requirements_template.first_question.id.to_s
      end
    rescue Exception => ex
      redirect_to(resource_contexts_path, :notice => "The DMP Template you're attempting to add resources for is incomplete") and return
    end

    @requirement = Requirement.find(params[:requirement_id])
    @institution = current_user.institution

###############################################
    #params for adding another resource
    @requirement_id = @requirement.id
    @template_id = @requirements_template.id
    @institution_id = @institution.id
    @customization_id = @customization.id
##############################################
    
    #determine type of customization
    if @customization.institution_id.nil?
      #this is a DMP customization
      @customization_type = 6 # the number from stephen's table for institution customization
    else
      @customization_type = 8 # A DMP admin customization directly for a funder's requirement
    end
  end

end
