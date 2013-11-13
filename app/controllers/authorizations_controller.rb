class AuthorizationsController < ApplicationController
	
	def add_authorization

    emails = params[:email].split(/,\s*/) unless params[:email] == ""
    @role_id = params[:role_id]
    @role_name = params[:role_name]
    @path = '/' + params[:p]    
    @invalid_emails = []
    @existing_emails = []
    emails.each do |email|
      @user = User.find_by(email: email)
      if @user.nil?
        @invalid_emails << email
      else
        
        if check_correct_permissions(@user.id, params[:role_id])           
          begin
            authorization = Authorization.create(role_id: @role_id, user_id: @user.id)
            authorization.save!
          rescue ActiveRecord::RecordNotUnique
            @existing_emails << email
          end
        else
          redirect_to @path, notice: "You don't have permission to grant this role."
        end
      end
    end
    respond_to do |format|
      if (!@invalid_emails.empty? && !@existing_emails.empty?)
        flash.now[:notice] = "Could not find Users with the following emails #{@invalid_emails.join(', ')} specified and Users with #{@existing_emails.join(', ')} already have been assigned this role. "
        format.js { render action: 'add_authorization' }
      elsif (!@existing_emails.empty? && @invalid_emails.empty?)
        flash.now[:notice] = "The following emails #{@existing_emails.join(', ')} have already been assigned with this role"
        format.js { render action: 'add_authorization' }
      elsif (@existing_emails.empty? && !@invalid_emails.empty?)
        flash.now[:notice] = "Could not find Users with the following emails #{@invalid_emails.join(', ')} specified. "
        format.js { render action: 'add_authorization' }
      else
        flash.now[:notice] = "Granted #{@role_name} Role to the Users specified."
        format.js { render action: 'add_authorization' }
      end
    end
  end


  def remove_authorization
    if check_correct_permissions( params[:user_id], params[:role_id] )

      @path = '/' + params[:p]   
      @authorization = Authorization.where(role_id: params[:role_id] , user_id: params[:user_id] )
      @authorization_id = @authorization.pluck(:id)
      @authorization.delete_all
      redirect_to @path, notice: "The Role has been revoked."
    else
      redirect_to @path, notice: "You don't have permission to revoke this role."
    end
  end

  private 

  def check_correct_permissions(user_id, role_id)
    user = User.find(user_id)  
    return (  

              current_user.has_role?(1) || 

              (  current_user.has_role?(5) && (current_user.institution == user.institution) && (role_id != 1)  ) || 

              ( current_user.has_role?(role_id) && (current_user.institution == user.institution) )   

            )
  end

end

