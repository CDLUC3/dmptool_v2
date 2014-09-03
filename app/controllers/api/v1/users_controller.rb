class Api::V1::UsersController < Api::V1::BaseController
	before_action :authenticate

	respond_to :json

	def index         
  	@users = User.all
	end 

	def show
    @user = User.find(params[:id])
  end


  protected
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      Ldap_User.valid_ldap_credentials?(username, password)
    end
  end


end