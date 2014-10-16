class Api::V1::UsersController < Api::V1::BaseController
	before_action :authenticate

  respond_to :json

	def index 
    if user_role_in?(:dmp_admin)
      @users = User.all
    elsif user_role_in?(:institutional_admin) 
      @users = User.where(institution_id: [current_user.institution.subtree_ids])
    else
      render json: 'You are not authorized to look at this content', status: 401
    end
	end 


	def show
    if @user = User.find_by_id(params[:id])
      if user_role_in?(:dmp_admin)
        @user
      elsif user_role_in?(:institutional_admin)
        if current_user.institution.subtree_ids.include?(@user.institution.id)
          @user
        else
          render json: 'You are not authorized to look at this content', status: 401
        end
      else
        render json: 'You are not authorized to look at this content', status: 401
      end
    else
      render json: 'The user you are looking for doesn\'t exist', status: 404
    end
  end


end