class Api::V1::RequirementsTemplatesController < Api::V1::BaseController

  include ApplicationHelper

  before_action :authenticate

  respond_to :json
  
  @@realm = "Templates"

  # ------------------------------------------------------------------------
  def index
    @user = User.find_by_id(session[:user_id])
    
    # If an institutional user, return the templates that the instition has used to make plans
    if user_role_in?(:institutional_admin, :institutional_reviewer, 
                                    :resource_editor, :template_editor)
      @requirements_templates = RequirementsTemplate.where("institution_id IN (?)", @user.institution.id).
                                        where(active: true).order(id: :asc).distinct

      @requirements_templates
    else
      render_unauthorized
    end
  end
    
  # ------------------------------------------------------------------------
  def show
    @user = User.find_by_id(session[:user_id])
    
    # Find the specified template
    if user_role_in?(:institutional_admin, :institutional_reviewer, 
                                        :resource_editor, :template_editor)
      @requirements_template = RequirementsTemplate.find_by_id(params[:id])

      # If we didn't find the template specified then they do not have access to it
      if @requirements_template
        # Return the template only if its active and belongs to the user's institution
        if @requirements_template.institution.id === @user.institution.id and
                                            @requirements_template.active
          @requirements_template
        else
          render_not_found
        end
      else
        render_not_found
      end
    else
      # No authorization sent so return an unauthorized message
      render_unauthorized
    end
  end
end
