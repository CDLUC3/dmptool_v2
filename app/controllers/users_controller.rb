class UsersController < ApplicationController

  before_action :require_login, except: [:create, :finish_signup, :finish_signup_update, :new]

  include InstitutionsHelper

  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :check_dmp_admin_access, only: [:index, :edit_user_roles, :update_user_roles, :destroy]
  before_action :require_logout, only: [:new]

  # GET /users
  # GET /users.json
  def index
    @admin_acr = params[:admin_acr]

    @all_users = params[:all_users]
    @all_institutions = params[:all_institutions]

    @q = params[:q]

    @users = User.order(:first_name, :last_name)
    @institutions = Institution.order(full_name: :asc)

    if (!@q.blank? && !@q.nil?)
      @users = @users.search_terms(@q)
    end

    case @all_users
      when "all"
        @users = @users.page(params[:page]).per(9999)
      else
        @users = @users.page(params[:page]).per(10)
    end

    case @all_institutions
      when "all"
        @institutions = @institutions.page(params[:page]).per(9999)
      else
        @institutions = @institutions.page(params[:page]).per(10)
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @user.institution_id = params[:institution_id] if params[:institution_id]
    @institution_list = InstitutionsController.institution_select_list
  end


  # GET /users/1/edit
  def edit
    unless can_edit_user?(params[:id])
      redirect_to(edit_user_path(current_user), notice: "You may not edit the user you were attempting to edit.  You're now editing your own information.") and return
    end
    @user = User.find(params[:id])
    @my_institution = @user.institution
    if user_role_in?(:dmp_admin)
      @institution_list = InstitutionsController.institution_select_list
    else
      @institution_list = @my_institution.root.subtree.collect {|i| ["#{'-' * i.depth} #{i.full_name}", i.id] }
    end

    @email_editable = ( @user.authentications.where(provider: 'shibboleth').count < 1 )

    @roles = @user.roles.map {|r| r.name}.join(' | ')

  end

  # POST /users
  # POST /users.json
  def create
    @institution_list = InstitutionsController.institution_select_list
    @user = User.new(user_params)
    @user.ldap_create = true

    existing_user = User.with_deleted.where(login_id: @user.login_id)
    if existing_user.length > 0
      existing_user = existing_user.first
      if !existing_user.deleted_at.blank? || existing_user.active == false
        redirect_to login_path, notice: "You already have a DMP Tool account with this username, but it's deactivated. Please contact us if you need to have it reactivated." and return
      end
      redirect_to login_path, notice: "You already have a DMP Tool account with this username. Please log in with your current username and password to continue." and return
    end


    @user.skip_email_uniqueness_validation = true
    if [@user.valid?].all?
      # if they already have a matching email in ldap then make the account the same login_id as that one
      ldap_user_by_email = nil
      begin
        ldap_user_by_email = Ldap_User::LDAP.fetch_by_email(@user.email)
      rescue LdapMixin::LdapException
      end
      @user.login_id = ldap_user_by_email[:uid].first if ldap_user_by_email

      begin
        results = Ldap_User::LDAP.fetch(@user.login_id)

        #fix up DMP account in LDAP so that it has dmpUser class, if needed
        unless results['objectclass'].include?('dmpUser')
          cl = Ldap_User::LDAP.fetch_attribute(@user.login_id, 'objectclass')
          cl = cl + ['dmpUser']
          Ldap_User::LDAP.replace_attribute(@user.login_id, 'objectclass', cl)
          results = Ldap_User::LDAP.fetch(@user.login_id)
        end
        existing_user = User.with_deleted.where(login_id: @user.login_id)

        #no existing LDAP User in DB so create one, but it already exists in LDAP
        if existing_user.length < 1
          @user.save
          redirect_to login_path, notice: "You've been added to the DMP Tool with your existing UC3 username, \"#{@user.login_id}\".  Please log in to continue." and return
        else
          #redirct to login, their record already exists.
          existing_user = existing_user.first
          redirect_to login_path, notice: "You already have a DMP Tool account. Your username is \"#{@user.login_id}\".  Please log in with your current password to continue." and return
        end
        @user.skip_email_uniqueness_validation = false
      rescue LdapMixin::LdapException => detail
        #couldn't fetch this user from LDAP if it got here
        @user.skip_email_uniqueness_validation = false

        if detail.message.include? 'does not exist'
          existing_user = User.with_deleted.where(email: @user.email)
          if existing_user.length > 0
            # user with existing Shibboleth Account
            existing_user = existing_user.first
            unless Ldap_User.add(@user.login_id, user_params[:password], "#{@user.first_name}", "#{@user.last_name}", @user.email)
              @display_text = "There were problems adding this user to the LDAP directory. Please contact uc3@ucop.edu."
              render action: 'new'
            else
              existing_user.login_id = @user.login_id
              if existing_user.save
                session[:user_id] = existing_user.id
                redirect_to edit_user_path(existing_user), notice: "This LDAP DMPTool account has been created.  You may also log in with 'Not in List' institution in addition to your Shibboleth account."
              end
            end
          else
            # user getting a new account
            User.transaction do
              if !Ldap_User.add(@user.login_id, user_params[:password], "#{@user.first_name}", "#{@user.last_name}", @user.email)
                @display_text = "There were problems adding this user to the LDAP directory. Please contact uc3@ucop.edu."
                render action: 'new'
              elsif @user.save
                @user.ensure_ldap_authentication(@user.login_id)
                session[:user_id] = @user.id
                redirect_to edit_user_path(@user), notice: 'User was successfully created.'
              end
            end
          end
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json

  def update
    if params[:id].to_i != current_user.id
      redirect_to edit_user_path(current_user) and return
    end
    @user = User.find(params[:id])
    @my_institution = @user.institution
    if user_role_in?(:dmp_admin)
      @institution_list = InstitutionsController.institution_select_list
    else
      @institution_list = @my_institution.root.subtree.collect {|i| ["#{'-' * i.depth} #{i.full_name}", i.id] }
    end

    @roles = @user.roles.map {|r| r.name}.join(' | ')

    @orcid_id = params[:user][:orcid_id]
    @update_orcid_id = params[:user][:update_orcid_id]

    if !@orcid_id.blank?
      #if valid_orcid?(@orcid_id)
        @orcid_id = "http://orcid.org/" + "#{@orcid_id}"
      #else
      #  flash[:error] = "The orcid id: #{@orcid_id} is a not valid orcid id."
      #  @orcid_id = ""
      #  redirect_to edit_user_path(@user)
      #  return
      #end
    end
    if !@update_orcid_id.blank?
      #if valid_orcid?(@update_orcid_id)
        @orcid_id = "http://orcid.org/" + "#{@orcid_id}"
      #else
      #  flash[:error] = "The orcid id: #{@update_orcid_id} is a not valid orcid id."
      #  @orcid_id = ""
      #  redirect_to edit_user_path(@user)
      #  return
      #end
    end
    
    User.transaction do
      #@user.institution_id = params[:user].delete(:institution_id)
      respond_to do |format|
        if @orcid_id.blank?     
          if @user.update_attributes(user_params)
            update_notifications(params[:prefs])
            # LDAP will not except for these two fields to be empty.
            #user_params[:first_name] = " " if user_params[:first_name].empty?
            #user_params[:last_name] = " " if user_params[:last_name].empty?
            update_ldap_if_necessary(@user, user_params)
            format.html { redirect_to edit_user_path(@user),
                        notice: 'User information updated.'  }
            format.json { head :no_content }
          else
            format.html { render 'edit'}
            format.json { head :no_content }    
          end
        
        else
          if (@user.update_attributes(user_params) && @user.update_attribute(:orcid_id, @orcid_id))
            update_notifications(params[:prefs])
            # LDAP will not except for these two fields to be empty.
            #user_params[:first_name] = " " if user_params[:first_name].empty?
            #user_params[:last_name] = " " if user_params[:last_name].empty?
            update_ldap_if_necessary(@user, user_params)
            format.html { redirect_to edit_user_path(@user),
                        notice: 'User information updated.'  }
            format.json { head :no_content }
          else
            format.html { render 'edit'}
            format.json { head :no_content }
          end
        end
      end
    end
  rescue LdapMixin::LdapException
    flash[:error] = 'Error updating LDAP. Local update canceled.'
    redirect_to edit_user_path(@user)
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def edit_user_roles
    @user = User.find(params[:user_id])
    @roles = Role.all
  end

  def finish_signup
    @user.first_name = @user.last_name = ''
  end

  def finish_signup_update
    if @user.update_attributes(params[:user].permit(:first_name, :last_name))
      flash[:notice] = 'You have completed signing up for the DMP tool.'
      redirect_to user_url(@user, :protocol => 'https')
    else
      render 'finish_signup'
    end
  end


  def update_user_roles

    @user_id = params[:user_id]
    @role_ids = params[:role_ids] ||= []  #"role_ids"=>["1", "2", "3"]

    u = User.find(@user_id)

    u.update_authorizations(@role_ids)

    respond_to do |format|
      format.html { redirect_to users_url(q: params[:q]), notice: 'User was successfully updated.'}
      format.json { head :no_content }
    end

  end


  def autocomplate_users_plans
    if !params[:name_term].blank?
      like = params[:name_term].concat("%")
      @users = User.where("CONCAT(first_name, ' ', last_name) LIKE ? ", like).active
    end
    list = map_users_for_autocomplete(@users)
    render json: list
  end


  def autocomplete_users
    role_number = params[:role_number].to_i
    if !params[:name_term].blank?
      like = params[:name_term].concat("%")
      u = User
      # u = current_user.institution.users_deep
      items = params[:name_term].split
      conditions1 = items.map{|item| "CONCAT(first_name, ' ', last_name) LIKE ?" }
      conditions2 = items.map{|item| "email LIKE ?" }
      conditions = "( (#{conditions1.join(' AND ')})" + ' OR ' + "(#{conditions2.join(' AND ')}) )"
      values = items.map{|item| "%#{item}%" }
      @users = u.where(conditions, *(values * 2) )
    end
    list = map_users_for_autocomplete(@users)
    render json: list
  end


  # def valid_orcid?(orcid_id)
  #   orcid_id.match(/[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}/)
  # end

  # def valid_email?(email)
  #   email.match(/\A[^@]+@[^@]+\.[^@]+\z/i)
  # end

  def remove_orcid
    @user = User.find(params[:user_id])
    @user.update_attribute(:orcid_id, nil)
    flash[:notice] = 'The orcid id has been successfully removed from your profile.'
    redirect_to edit_user_path(@user.id)
  end

  # def valid_password (password, confirmation)
  #   !password.blank? &&
  #   !confirmation.blank? &&
  #   password == confirmation &&
  #   (8..30).include?(password.length) &&
  #   password.match(/\d/) &&
  #   password.match(/[A-Za-z]/)
  # end

  private


  def map_users_for_autocomplete(users)
    @users.map {|u| Hash[ id: u.id, full_name: u.full_name, label: u.label]}
  end

  def reset_ldap_password(user, password)
    Ldap_User.find_by_email(user.email).change_password(password)
  end

  def legal_password(password)
    (8..30).include?(password.length) and password.match(/\d/) and password.match(/[A-Za-z]/)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:institution_id, :email, :first_name, :last_name,
                                 :password, :password_confirmation, :prefs,:user_id, :login_id, role_ids: [] )
  end

  def update_ldap_if_necessary(user, params)
    ldap_auths = user.authentications.where(provider: :ldap)
    return if ldap_auths.count != 1
    ldap_auth = ldap_auths.first
    ldap_user = Ldap_User.find_by_id(ldap_auth.uid)
    {:email => :mail, :last_name => :sn, :first_name => :givenname}.each do |k, v|
      if params[k]
        ldap_user.set_attrib_dn(v, params[k]) unless params[k].empty?
      end
    end
    if !params[:password].blank? && (params[:password] == params[:password_confirmation])
      ldap_user.change_password(params[:password])
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def update_notifications (prefs)
    # Set all preferences to false
    @user.prefs.each do |key, value|
      value.each_key do |k|
        @user.prefs[key][k] = false
      end
    end

    # Sets the preferences the user wants to true
    prefs.each_key do |key|
      prefs[key].each_key do |k|
        @user.prefs[key.to_sym][k.to_sym] = true
      end
    end

    @user.save
  end


  def require_current_user
    @user = User.find(params[:id])
    unless @user == current_user
      flash[:error] = "User information may only be edited by that user"
      redirect_to root_path
    end
  end

  def can_edit_user?(user_id)
    return false if current_user.blank? || user_id.blank?
    return true if current_user.id == user_id.to_i
    return true if user_role_in?(:dmp_admin)
    if user_role_in?(:institutional_admin)
      u = User.find_by_id(user_id)
      return false if u.nil?
      if current_user.institution.subtree_ids.include?(u.institution.id)
        return true
      end
    end
    return false
  end


end
