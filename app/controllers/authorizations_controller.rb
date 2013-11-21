class AuthorizationsController < ApplicationController
	
	def add_authorization

    emails = params[:email].split(/,\s*/) unless params[:email] == ""
    @role_id = (params[:role_id]).to_i
    @role_name = params[:role_name]
    @path = '/' + params[:p]    
    @invalid_emails = []
    @existing_emails = []
    emails.each do |email|
      @user = User.find_by(email: email)
      if @user.nil?
        @invalid_emails << email
      else
        
        if check_correct_permissions(@user.id, @role_id)  
          @check = true         
          begin
            authorization = Authorization.create(role_id: @role_id, user_id: @user.id)
            authorization.save!
          rescue ActiveRecord::RecordNotUnique
            @existing_emails << email
          end
        else
          @check = false   
        end
      end
    end
    respond_to do |format|
      if (!@invalid_emails.empty? && !@existing_emails.empty?)
        flash.now[:notice] = "Could not find Users with the following emails #{@invalid_emails.join(', ')} specified and Users with #{@existing_emails.join(', ')} already have been assigned this role. "
        format.js { render action: 'add_authorization' }
        return    
      elsif (!@existing_emails.empty? && @invalid_emails.empty?)
        flash.now[:notice] = "The following emails #{@existing_emails.join(', ')} have already been assigned with this role"
        format.js { render action: 'add_authorization' }
        return
      elsif (@existing_emails.empty? && !@invalid_emails.empty?)
        flash.now[:notice] = "Could not find Users with the following emails #{@invalid_emails.join(', ')} within your institution. "
        format.js { render action: 'add_authorization' }
        return
      elsif !@check
        flash.now[:notice] = "Permission error."
        format.js { render action: 'add_authorization' }
        return 
      else
        flash.now[:notice] = "Granted #{@role_name} Role to the Users specified."
        format.js { render action: 'add_authorization' }
        return
      end
    end
  end


  def remove_authorization
    @path = '/' + params[:p]
    @role_id = (params[:role_id]).to_i
    if check_correct_permissions( params[:user_id], @role_id )
      @authorization = Authorization.where(role_id: @role_id , user_id: params[:user_id] )
      @authorization_id = @authorization.pluck(:id)
      @authorization.delete_all
      redirect_to @path, notice: "The Role has been revoked."
    else
      redirect_to @path, notice: "You don't have permission to revoke this role."
    end
    return
  end

   

  def check_correct_permissions(user_id, role_id)
    
    a = false
    user = User.find(user_id)  
    a =   

              safe_has_role?(Role::DMP_ADMIN) || 

              (  safe_has_role?(Role::INSTITUTIONAL_ADMIN) &&(safe_institution == user.institution) && (role_id != Role::DMP_ADMIN)  ) || 

              ( safe_has_role?(role_id) && (safe_institution == user.institution) )   
    return a
            
  end

end

