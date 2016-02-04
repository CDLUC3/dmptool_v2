class Api::V1::RequirementsTemplatesController < Api::V1::BaseController

  include ApplicationHelper

  before_action :authenticate

  respond_to :json
  
  @@realm = "Templates"

  # ------------------------------------------------------------------------
  def index
    @user = User.find_by_id(session[:user_id])
    
    # If an institutional user, return the templates that the instition has used to make plans
    if user_role_in?(:institutional_admin, :institutional_reviewer, :resource_editor, :template_editor)
      @requirements_templates = RequirementsTemplate.where("institution_id IN (?)", @user.institution.id).
                                        where(active: true).order(id: :asc).distinct
                                        
puts @user.institution.id
      @requirements_templates
    else
      render_unauthorized
    end
  end
    
  # ------------------------------------------------------------------------
  def show
    @user = User.find_by_id(session[:user_id])
    
    # If an institutional user, return the templates that the instition has used to make plans
    if user_role_in?(:institutional_admin, :institutional_reviewer, :resource_editor, :template_editor)
      @requirements_template = RequirementsTemplate.where("institution_id IN (?)", @user.institution.id).
                                      where(active: true).where(id: params[:id])

      # If we didn't find the template specified then they do not have access to it
      if @requirements_template.empty?
        render_unauthorized
      else
        @requirements_template
      end
    else
      # No authorization sent so return an unauthorized message
      render_unauthorized
    end
  end
end
