class UsersController < ApplicationController
  include InstitutionsHelper

  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :check_dmp_admin_access, only: [:index, :edit_user_roles, :update_user_roles, :destroy]

  # GET /users
  # GET /users.json
  def index
    case params[:scope]
      when "all_users"
        @users = User.page(params[:page]).order(login_id: :asc)
      else
        @users = User.page(params[:page]).order(login_id: :asc).per(10)
    end
    case params[:scope]
      when "all_institutions"
        @institutions = Institution.page(params[:page])
      else
        @institutions = Institution.page(params[:page]).per(10)
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @institution_list = Institution.all
  end

  # GET /users/1/edit
  def edit

    @user = User.find(params[:id])
    @my_institution = @user.institution

    @institution_list = my_profile_institution_list(@my_institution)

    @roles = @user.roles.map {|r| r.name}.join(' | ')

  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.ldap_create = true
    if [@user.valid?, valid_password(user_params[:password], user_params[:password_confirmation])].all?
      begin
        results = Ldap_User::LDAP.fetch(@user.login_id)
        if results['objectclass'].include?('dmpUser')
          @display_text = "A DMPTool account with this login already exists.  Please login."
        else
          @display_text = "Please contact uc3@ucop.edu to add your DMPTool account manually."
        end
      rescue LdapMixin::LdapException => detail
        if detail.message.include? 'does not exist'
          # Add the user, spaces are in place of the first/last name as LDAP requires these.
          User.transaction do
            if !Ldap_User.add(@user.login_id, user_params[:password], ' ', ' ', @user.email)
              @display_text = "There were problems adding this user to the LDAP directory. Please contact uc3@ucop.edu."
            elsif @user.save
              @user.ensure_ldap_authentication(@user.login_id)
              @display_text = "This DMPTool account has been created."
            end
          end
        end
      end
    end

    respond_to do |format|
      if !@user.errors.any? && @user.save
        session[:user_id] = @user.id
        format.html { redirect_to edit_user_path(@user), notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json

  def update
    password = user_params[:password]
    password_confirmation = user_params[:password_confirmation]

    if password && !password.empty?
      if valid_password(password, password_confirmation)
        begin
          reset_ldap_password(@user, password)
        rescue
          flash[:notice] = "Problem updating password in LDAP. Please retry."
          render :edit and return
        end
      else
        render :edit and return
      end
    end


    User.transaction do
      @user.institution_id = params[:user].delete(:institution_id)
      if @user.update_attributes(user_params)

        update_notifications(params[:prefs])
        # LDAP will not except for these two fields to be empty.
        user_params[:first_name] = " " if user_params[:first_name].empty?
        user_params[:last_name] = " " if user_params[:last_name].empty?
        update_ldap_if_necessary(@user, user_params)
        flash[:notice] = 'User information updated.'
        redirect_to edit_user_path(@user)
      else
        render 'edit'
      end
    end
  rescue LdapMixin::LdapException
    flash[:notice] = 'Error updating LDAP. Local update canceled.'
    redirect_to edit_user_path(@user)
  rescue Exception => e
    puts e.to_s
    flash[:notice] = 'Unknown error updating user information.'
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

    remove_all_user_authorizations(@user_id)

    @role_ids.each do |role_id|
      role_id = role_id.to_i
      authorization = Authorization.create(role_id: role_id, user_id: @user_id)
      authorization.save!
    end

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully updated.'}
      format.json { head :no_content }
    end

  end
  
  def autocomplete_template_editors
    if !params[:name_term].blank?
      like = "%".concat(params[:name_term].concat("%"))
      if current_user.has_role?(Role::DMP_ADMIN)
        u = User
      elsif current_user.has_role?(Role::INSTITUTIONAL_ADMIN) || current_user.has_role?(Role::TEMPLATE_EDITOR)
        u = current_user.institution.users_deep
      end
      @users = u.where("CONCAT(first_name, ' ', last_name) LIKE ?", like).active
    end
    list = @users.map {|u| Hash[ id: u.id,
      name: u.full_name,
      label: "#{u.full_name} <#{u.email}>"]}
    render json: list
  end

  private



  def remove_all_user_authorizations(user_id)
    @authorization = Authorization.where(user_id: user_id)
    @authorization.delete_all
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
                                 :password, :password_confirmation, :prefs, :login_id, role_ids: [])
  end

  def update_ldap_if_necessary(user, params)
    return unless session[:login_method] == 'ldap'
    ldap_user = Ldap_User.find_by_id(user.login_id)
    {:email => :mail, :last_name => :sn, :first_name => :givenname}.each do |k, v|
      if params[k]
        ldap_user.set_attrib_dn(v, params[k]) unless params[k].empty?
      end
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

  def valid_password (password, confirmation)
    @user.errors.add(:password, " is required.") if password.blank?
    @user.errors.add(:password_confirmation, " is required.") if confirmation.blank?
    @user.errors.add(:base, "Your password and repeated password do not match.") if password != confirmation
    @user.errors.add(:base, "Your password must be 8 to 30 characters long.") unless (8..30).include?(password.length)
    unless password.match(/\d/) and password.match(/[A-Za-z]/)
      @user.errors.add(:base, "Your password must contain at least one number and at least one letter.")
    end

    !@user.errors.any?
  end

  def require_current_user
    @user = User.find(params[:id])
    unless @user == current_user
      flash[:notice] = "User information may only be edited by that user"
      redirect_to root_path
    end
  end


end
