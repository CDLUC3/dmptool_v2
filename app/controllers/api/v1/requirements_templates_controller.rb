class Api::V1::RequirementsTemplatesController < Api::V1::BaseController

  include ApplicationHelper

  before_action :soft_authenticate
  before_action :request_params

  respond_to :json

  # ------------------------------------------------------------------------
  def index
    @public_templates, @institutional_templates = [], []
    
    if @user = User.find_by_id(session[:user_id]) and params[:visibility] != 'public'
      # If this is a DMP_ADMIN retrieve all of the institutional templates
      if user_role_in?(:dmp_admin)
        @institutional_templates = RequirementsTemplate.institutional_visibility
        
      # Otherwise only collect the templates for the user's institution
      elsif user_role_in?(:institutional_admin, :institutional_reviewer, 
                          :resource_editor, :template_editor)
        @institutional_templates = RequirementsTemplate.institutional_visibility.where(institution: @user.institution)
        
      end
    end
    
    if params[:visibility] != 'institutional'
      @public_templates = RequirementsTemplate.public_visibility
    end
    
    @requirements_templates = @public_templates + @institutional_templates
    
    if params[:visibility]
      @requirements_templates.select{|t| t.visibility === params[:visibility]}
    end
    
  end

  # ------------------------------------------------------------------------
  def show
    @requirements_template = RequirementsTemplate.public_visibility.find_by_id(params[:id])
    
    # If the template is NOT publicly accessibly
    unless @requirements_template
      # If the template exists
      if RequirementsTemplate.find_by_id(params[:id])
        
        if @user = User.find_by_id(session[:user_id])
          # If this is a DMP_ADMIN
          if user_role_in?(:dmp_admin)
            @requirements_template = RequirementsTemplate.find_by_id(params[:id])
        
          # Otherwise if they are a institutional admin they can see institutional or private
          elsif user_role_in?(:institutional_admin, :institutional_reviewer, 
                               :resource_editor, :template_editor)
                               
            @requirements_template = RequirementsTemplate.institutional_visibility.
                          where(institution: @user.institution).find_by_id(params[:id])

            unless @requirements_template
              render json: 'You are not authorized to view this content.', status: 401
            end

          else
            render json: 'You are not authorized to view this content.', status: 401
          end
        
        else
          render json: 'You are not authorized to view this content.', status: 401
        end
        
      else
        render json: 'The template you are looking for doesn\'t exist', status: 404
      end
    end
  end
  
  private
    def request_params
      params.permit(:visibility)
    end
end
