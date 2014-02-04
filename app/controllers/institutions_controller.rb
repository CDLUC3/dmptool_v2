class InstitutionsController < ApplicationController
  before_action :set_institution, only: [:show, :destroy]
  before_action :check_for_cancel, :update => [:create, :update, :destroy]
  before_filter :populate_institution_select_list
  before_action :check_institution_admin_access

  # GET /institutions
  # GET /institutions.json
  def index

    if safe_has_role?(Role::DMP_ADMIN)
      @institutions = Institution.all
    else
      @institutions = Institution.where(id: [current_user.institution.subtree_ids])
    end

    @institution = Institution.new(:parent_id => params[:parent_id])

    @current_institution = current_user.institution

    @institution_users = institutional_admins

    @categories.delete_if {|i| i[1] == @institution.id}

    manage_users

  end


  def manage_users
    @users = current_user.institution.users_deep_in_any_role.order(last_name: :asc)
    @roles = Role.where(['id NOT IN (?)', 1])
  end

  

  #every roles except DMP Admin
  def edit_user_roles_inst_admin
    @user = User.find(params[:user_id])
    @roles = Role.where(['id NOT IN (?)', 1]) 
  end

  def update_user_roles_inst_admin
    @user_id = params[:user_id]
    @role_ids = params[:role_ids] ||= []  #"role_ids"=>["1", "2", "3"]

    remove_user_authorizations_not_dmp_admin(@user_id)

    @role_ids.each do |role_id|
      role_id = role_id.to_i
      authorization = Authorization.create(role_id: role_id, user_id: @user_id)
      authorization.save!
    end

    respond_to do |format|
      format.html { redirect_to institutions_url, notice: 'User was successfully updated.'}
      format.json { head :no_content }
    end
  end

  def remove_user_authorizations_not_dmp_admin(user_id)
    @authorization = Authorization.where(user_id: user_id)
    @authorization.delete_all(['role_id NOT IN (?)', 1])  
  end

  # GET /institutions/1
  # GET /institutions/1.json
  def show
  end

  # GET /institutions/new
  def new
    @current_institution = Institution.new(:parent_id => params[:parent_id])
  end

  # GET /institutions/1/edit
  def edit
    @current_institution = Institution.find(params[:id])
    #@institution = Institution.find(params[:id])
  end

  # POST /institutions
  # POST /institutions.json
  def create
    @current_institution = Institution.new(institution_params)

    respond_to do |format|
      if @current_institution.save
        format.html { redirect_to edit_institution_path(@current_institution), notice: 'Institution was successfully created.' }
        format.json { render action: 'show', status: :created, location: @current_institution }
      else
        format.html { render action: 'new' }
        format.json { render json: @current_institution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /institutions/1
  # PATCH/PUT /institutions/1.json
  def update
    @current_institution = Institution.find(params[:id])
    respond_to do |format|
      if @current_institution.update(institution_params)
        format.html { redirect_to edit_institution_path(@current_institution), notice: 'Institution was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @current_institution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /institutions/1
  # DELETE /institutions/1.json
  def destroy
    @institution.destroy
    respond_to do |format|
      format.html { redirect_to institutions_url }
      format.json { head :no_content }
    end
  end

  def populate_institution_select_list
    @categories = InstitutionsController.institution_select_list
  end

  def self.institution_select_list
    ancestry_options(Institution.unscoped.arrange(order: :full_name)){|i| "#{'-' * i.depth} #{i.full_name}" }
  end

  def self.ancestry_options(items, &block)
    return ancestry_options(items){ |i| "#{'-' * i.depth} #{i.full_name}" } unless block_given?

    result = []
    items.map do |item, sub_items|
      result << [yield(item), item.id]
      #this is a recursive call:
      result += ancestry_options(sub_items, &block)
    end
    result
  end

  def toggle_active
    @resource_template.toggle!(:active)
    respond_to do |format|
      format.js
    end
  end


  def institutional_admins
    @user_ids = Authorization.where(role_id: 5).pluck(:user_id) #All the institutional_admins
    if safe_has_role?(Role::DMP_ADMIN)
      @users = User.where(id: @user_ids).order('created_at DESC').page(params[:page]).per(10)
    else
      @users = User.where(id: @user_ids, institution_id: [current_user.institution.subtree_ids]).order('created_at DESC').page(params[:page]).per(10)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_institution
      @institution = Institution.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def institution_params
      params.require(:institution).permit(:full_name, :nickname, :desc, :contact_info, :contact_email, :url, :url_text, :shib_entity_id, :shib_domain, :logo, :remote_logo_url, :parent_id)
    end

    def check_for_cancel
      redirect_to :back if params[:commit] == "Cancel"
    end

end






