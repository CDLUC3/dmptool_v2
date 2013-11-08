class AuthorizationsController < ApplicationController


	#to be completed
	def authorize(role_id)
    @autorization = Authorization.find(params[:role_id], params[:user_id])
  end

end
