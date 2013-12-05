class AuthorizationsController < ApplicationController
	
	def add_authorization

    emails = params[:email].split(/,\s*/) unless params[:email] == ""
    @role_id = (params[:role_id]).to_i
    @role_name = params[:role_name]
    @path = '/' + params[:p]    
    @invalid_emails = []
    @existing_emails = []
    @outside_emails = []
    @saved_emails = []
   
    emails.each do |email|
      @user_saved = false
      @user = User.find_by(email: email)
      if @user.nil?
        @invalid_emails << email
      else 

        if check_correct_permissions(@user.id, @role_id) 
          @user_saved = true
                
          begin
            authorization = Authorization.create(role_id: @role_id, user_id: @user.id)
            authorization.save!
          rescue ActiveRecord::RecordNotUnique
            @existing_emails << email
            @user_saved = false
          end

        else
          @outside_emails << email  
        end

        @saved_emails << email if @user_saved

      end
    end

    respond_to do |format|

      @message = ""

      if !@invalid_emails.empty?
        @message << "Could not find Users with the following " + "email".pluralize(@invalid_emails.count) + 
                    ": #{@invalid_emails.join(', ')}."
      end

      if !@existing_emails.empty?
        @message << "The following " + "user".pluralize(@existing_emails.count) +
                    ": #{@existing_emails.join(', ')}  " +
                    pluralize_has(@existing_emails.count) + " already been assigned this role."
      end
      
      if !@outside_emails.empty?
        @message << "You cannot grant this role to users outside your institution: #{@outside_emails.join(', ')}. Please contact the DMP Administrator.\n"
      end

      if !@saved_emails.empty?
        @message << "Role granted to the following " + "user".pluralize(@saved_emails.count) + ": #{@saved_emails.join(', ')}  "
      end

      flash.now[:notice] = @message
      format.js { render action: 'add_authorization' }
      return
    end

  end


  def remove_authorization
    @path = '/' + params[:p]
    @role_id = (params[:role_id]).to_i
    if check_correct_permissions( params[:user_id], @role_id )
      @authorization = Authorization.where(role_id: @role_id , user_id: params[:user_id] )
      @authorization_id = @authorization.pluck(:id)
      @authorization.delete_all
      redirect_to @path, notice: "The role has been revoked."
    else
      redirect_to @path, notice: "You don't have permission to revoke this role."
    end
    return
  end

   

  def check_correct_permissions(user_id, role_id)
    
    user = User.find(user_id)  
    a =   safe_has_role?(Role::DMP_ADMIN) || 

          (   

            current_user.has_role?(Role::INSTITUTIONAL_ADMIN) && 

            current_user.institution.subtree_ids.include?(user.institution_id) 

          )  || 

          (

            safe_has_role?(role_id) && 

            current_user.institution.subtree_ids.include?(user.institution_id) 

          )

    return a
            
  end

  private

  def pluralize_has(count)
    if count > 1
      "have"
    else
      "has"
    end
  end


end




















