class CustomizationsController < ApplicationController

  # information to display the repetitive tabs
  # name is tab name
  # partial is the partial to display
  # scope is the scope to use from the requirements table
  # requirement_only means that this item can only be displayed when attached to a
  # specific requirement -- it shouldn't be displayed if erroneously attached as global or template-level resource
  # the suggested responses and example responses can only be displayed for a specific requirement
  TABS = [  {name: 'Guidance', partial: 'guidance_item', scope: :guidance, requirement_only: false},
            {name: 'Actionable Links', partial: 'actionable_url_item', scope: :actionable_url, requirement_only: false},
            {name: 'Suggested Response', partial: 'guidance_item', scope: :suggested_response, requirement_only: true},
            {name: 'Example Response', partial: 'guidance_item', scope: :example_response, requirement_only: true }
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


    suggested_responses = @requirement.resources(@customization.institution_id).count
    example_responses = @requirement.resources(@customization.institution_id).count

    #can only show suggested responses or example responses when one has an item and the other doesn't
    if suggested_responses > 0
      TABS.delete_at(3)
    elsif example_responses > 0
      TABS.delete_at(2)
    end


    ###############################################
    #params for adding another resource
    @requirement_id = @requirement.id
    @template_id = @requirements_template.id
    @customization_id = @customization.id
    @resource_level = "requirement"
##############################################
    

  end

end
