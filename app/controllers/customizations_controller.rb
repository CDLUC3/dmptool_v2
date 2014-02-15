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
  end

end
