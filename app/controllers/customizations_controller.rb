class CustomizationsController < ApplicationController

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
    #determine type of customization
    if @customization.institution_id.nil?
      #this is a DMP customization
      @customization_type = 6 # the number from stephen's table for institution customization
    else
      @customization_type = 8 # A DMP admin customization directly for a funder's requirement
    end
  end

end
