class CustomizationsController < ApplicationController

  def show
    # :id is customization id and :requirement_id
    @customization = ResourceContext.find(params[:id])
    redirect_to(dashboard_path) unless @customization.resource_id.blank? #must be blank, otherwise this isn't a container
    @requirements_template = @customization.requirements_template
    @requirements = @requirements_template.requirements
    if params[:requirement_id].blank?
      params[:requirement_id] = @requirements.roots.order(:order).first.id
    end
  end

end