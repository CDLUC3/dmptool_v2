class Api::V1::UsersController < Api::V1::BaseController
	
  before_action :soft_authenticate
   #before_action :authenticate

  @@realm = "Users"
   
  respond_to :json

	def index 
    if user_role_in?(:dmp_admin)
      @users = User.all
    elsif user_role_in?(:institutional_admin) 
      @users = User.where(institution_id: [current_user.institution.root.subtree_ids])
    else
      render_unauthorized
    end
	end 


	def show
    if @user = User.find_by_id(params[:id])
      if user_role_in?(:dmp_admin)
        @user
      elsif user_role_in?(:institutional_admin)
        if current_user.institution.root.subtree_ids.include?(@user.institution.id)
          @user
        else
          render_unauthorized
        end
      else
        render_unauthorized
      end
    else
      render_not_found
    end
  end


end