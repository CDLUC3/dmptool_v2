class AuthorizationsController < ApplicationController

  before_action :require_login, except: [:pluralize_has]
	
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

        #if (check_correct_permissions(@user.id, @role_id) ||  user_role_in?(:dmp_admin))
        if (check_correct_permissions(@user.id, @role_id))
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
        flash.now[:notice] = @message
      else
        flash.now[:error] = @message
      end

      
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
      flash[:error] =  "You don't have permission to revoke this role."
      redirect_to @path and return
    end
    return
  end
  
  def add_role_autocomplete
    u_name, u_id = nil, nil
    params.each do |k,v|
      u_name = v if k.end_with?('_name')
      u_id = v if k.end_with?('_id')
    end
    role_number = params[:role_number].to_i
    item_description = params[:item_description]
    
    if u_name.blank?
      flash[:error] =  "Please select a person to add as a #{item_description}."
      redirect_to :back and return 
    end
    if !u_id.blank?
      user = User.find(u_id)
    else
      first, last = u_name.split(" ", 2)
      if first.nil? || last.nil?
        flash[:error] =  "Please type and select the full name or email of a user."
        redirect_to :back and return 
      end
      users = User.where("first_name = ? and last_name = ?", first, last)
      if users.length > 1
        flash[:error] =  "Please select the user with this name from the list.  There is more than one user with this name."
        redirect_to :back and return 
      end
      if users.length < 1
        flash[:error] =  "The user you entered was not found"
        redirect_to :back and return 
      end
      user = users.first
    end
    if user.roles.map{|i| i.id}.include?(role_number)
      flash[:error] =  "The user you chose is already a #{item_description}"
      redirect_to :back and return
    end
    if !check_correct_permissions(user.id, role_number)
      flash[:error] =  "You do not have permission to assign this role."
      redirect_to :back  and return 
    end
    authorization = Authorization.create(role_id: role_number, user_id: user.id)
    authorization.save!
    redirect_to :back, notice: "#{user.full_name} has been added as a #{item_description}."
  end

  def add_authorization_manage_users
     @role_ids = params[:role_ids] ||= []  #"role_ids"=>["1", "2", "3"]
    u_name, u_id = nil, nil
    params.each do |k,v|
      u_name = v if k.end_with?('_name')
      u_id = v if k.end_with?('_id')
    end
    role_number = params[:role_number].to_i
    #item_description = params[:item_description]
    
    if u_name.blank?
      flash[:error] =  "Please select a user"
      redirect_to :back and return 
    end
    if !u_id.blank?
      user = User.find(u_id)
    else
      first, last = u_name.split(" ", 2)
      if first.nil? || last.nil?
        flash[:error] =  "Please type and select the full name or email of a user."
        redirect_to :back and return 
      end
      users = User.where("first_name = ? and last_name = ?", first, last)
      if users.length > 1
        flash[:error] =  "Please select the user with this name from the list.  There is more than one user with this name."
        redirect_to :back and return 
      end
      if users.length < 1
        flash[:error] =  "The user you entered was not found"
        redirect_to :back and return 
      end
      user = users.first
    end
     #if (user.institution != current_user.institution && !user_role_in?(:dmp_admin))
     if (user.institution != current_user.institution )
      flash[:error] = "The user you chose belongs to a different institution."
      redirect_to :back and return
    end
    if user.has_any_role?
      flash[:error] =  "The user you chose has already been granted a role. You can click on 'Edit User' to grant other roles."
      redirect_to :back and return
    end
    if  @role_ids == []
      flash[:error] =  "Please select at least a role to grant"
      redirect_to :back and return
    end
     @role_ids.each do |role_id|
      role_id = role_id.to_i
      authorization = Authorization.create(role_id: role_id, user_id: user.id)
      authorization.save!
    end
    # unless check_correct_permissions(user.id, role_number)
    #   redirect_to :back, notice: "You do not have permission to assign this role" and return 
    # end
    # authorization = Authorization.create(role_id: role_number, user_id: user.id)
    # authorization.save!
    #redirect_to :back, notice: "#{user.full_name} has been added as a #{item_description}"
    redirect_to :back, notice: "#{user.full_name} has been updated"
  end

   

  def check_correct_permissions(user_id, role_id)
    
    user = User.find(user_id)
    user_role_in?(:dmp_admin) ||
      ( user_role_in?(:institutional_admin) &&
        current_user.institution.subtree_ids.include?(user.institution_id) 
      ) || 
      ( safe_has_role?(role_id) && 
        current_user.institution.subtree_ids.include?(user.institution_id) 
      )     
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
