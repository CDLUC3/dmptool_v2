class Api::V1::InstitutionsController < Api::V1::BaseController
  #before_action :require_admin
	 
	respond_to :json

	def index         
  	@institutions = Institution.all 
	end 

	def show
    	@institution = Institution.find(params[:id])
  end  

	def plans_count_show
  	@institution = Institution.find(params[:id])
	end 

	def plans_count_index
  	@institutions = Institution.all 
	end 

	def admins_count_show
  	@institution = Institution.find(params[:id])
	end 

	def admins_count_index
  	@institutions = Institution.all 
	end	

  def require_admin
    unless user_role_in?(:dmp_admin)
      flash[:error] = "You must be an administrator to access this page."
      session[:return_to] = request.original_url
      redirect_to choose_institution_path and return
    end
  end

  

end