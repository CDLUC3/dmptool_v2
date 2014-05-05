class InstitutionsController < ApplicationController

  before_action :require_login, :except=>[:partners_list]
  before_action :set_institution, only: [:show, :destroy]
  before_action :check_for_cancel, :update => [:create, :update, :destroy]
  before_filter :populate_institution_select_list, only: [:index, :new, :create]
  before_action :check_institution_admin_access, :except=>[:partners_list]

  include InstitutionsHelper

  # GET /institutions
  # GET /institutions.json
  def index

    @current_institution = current_user.institution

    if user_role_in?(:dmp_admin)
      @institutions = Institution.all
      @disabled = false 
    else
      @institutions = Institution.where(id: [current_user.institution.root.subtree_ids])
      @disabled = true
      
      @sub_institutions = @current_institution.root.subtree.collect {|i| ["#{'-' * i.depth} #{i.full_name}", i.id] }
      @sub_institutions.delete_if {|i| i[1] == @current_institution.id}
    end

    @institution = Institution.new(:parent_id => params[:parent_id])

    @institution_users = institutional_admins

    @categories.delete_if {|i| i[1] == current_user.institution.id}

    manage_users

    institutional_resources

    @tab_number = 'tab_tab2' #the tab number for the maze of editing resources from everywhere
    #@anchor = params[:anchor]
   
  end


  def institutional_resources
    @resource_contexts = ResourceContext.includes(:resource).
                          where(requirements_template_id: nil, requirement_id: nil, institution_id: [current_user.institution.subtree_ids]).
                          where("resource_id IS NOT NULL")
    @resources_count = @resource_contexts.count
    case params[:scope]
      when "all"
        @resource_contexts = @resource_contexts.page(params[:page]).per(100)
      else
        @resource_contexts = @resource_contexts.page(params[:page]).per(5)
    end

  end


  def manage_users

    if user_role_in?(:dmp_admin)
      case params[:scope]
        when "resources_editor"
          @users = @current_institution.users_in_role_any_institution("Resources Editor").order(last_name: :asc)
        when "template_editor"
           @users = @current_institution.users_in_role_any_institution("Template Editor").order(last_name: :asc)
        when "institutional_administrator"
           @users = @current_institution.users_in_role_any_institution("Institutional Administrator").order(last_name: :asc)
        when "institutional_reviewer"
          @users = @current_institution.users_in_role_any_institution("Institutional Reviewer").order(last_name: :asc)
        when "dmp_administrator"
          @users =  @current_institution.users_in_role_any_institution("DMP Administrator").order(last_name: :asc)
        else
          @users = @current_institution.users_deep_in_any_role_any_institution.order(last_name: :asc)
      end
      @roles = Role.where(['id NOT IN (?)', 1])
      count_any_institution
    else
      case params[:scope]
        when "resources_editor"
          @users = @current_institution.users_in_role("Resources Editor").order(last_name: :asc)
        when "template_editor"
           @users = @current_institution.users_in_role("Template Editor").order(last_name: :asc)
        when "institutional_administrator"
           @users = @current_institution.users_in_role("Institutional Administrator").order(last_name: :asc)
        when "institutional_reviewer"
          @users = @current_institution.users_in_role("Institutional Reviewer").order(last_name: :asc)
        when "dmp_administrator"
          @users =  @current_institution.users_in_role("DMP Administrator").order(last_name: :asc)
        else
          @users = @current_institution.users_deep_in_any_role.order(last_name: :asc)
      end
      @roles = Role.where(['id NOT IN (?)', 1])
      count
    end
  end

  def count  
    @all = @current_institution.users_deep_in_any_role.count
    @resources_editor =@current_institution.users_in_role("Resources Editor").count
    @template_editor = @current_institution.users_in_role("Template Editor").count
    @institutional_administrator =@current_institution.users_in_role("Institutional Administrator").count
    @dmp_administrator = @current_institution.users_in_role("DMP Administrator").count
    @institutional_reviewer = @current_institution.users_in_role("Institutional Reviewer").count
  end

  def count_any_institution  
    @all = @current_institution.users_deep_in_any_role_any_institution.count
    @resources_editor =@current_institution.users_in_role_any_institution("Resources Editor").count
    @template_editor = @current_institution.users_in_role_any_institution("Template Editor").count
    @institutional_administrator =@current_institution.users_in_role_any_institution("Institutional Administrator").count
    @dmp_administrator = @current_institution.users_in_role_any_institution("DMP Administrator").count
    @institutional_reviewer = @current_institution.users_in_role_any_institution("Institutional Reviewer").count
  end

  #every roles except DMP Admin
  def edit_user_roles_inst_admin
    @user = User.find(params[:user_id])
    @roles = Role.where(['id NOT IN (?)', 1]) 
  end

  def update_user_roles_inst_admin
    @user_id = params[:user_id]
    @role_ids = params[:role_ids] ||= []  #"role_ids"=>["1", "2", "3"]

    @role_ids = (@role_ids.map{|i| i.to_i }) & [2, 3, 4, 5] # selected from normal roles

    @user = User.find(@user_id)
    @role_ids += [1] if @user.roles.pluck(:id).include?(1) #can't change role #1, but need to keep it in array

    @user.update_authorizations(@role_ids)

    respond_to do |format|
      format.html { redirect_to institutions_url, notice: 'User was successfully updated.'}
      format.json { head :no_content }
    end
  end

  # GET /institutions/1
  # GET /institutions/1.json
  def show
  end

  # GET /institutions/new
  def new
    @current_institution = Institution.new(:parent_id => params[:parent_id])
    @sub_institutions = @current_user.institution.root.subtree.collect {|i| ["#{'-' * i.depth} #{i.full_name}", i.id] }
   
  end

  # GET /institutions/1/edit
  def edit
    @acr = params[:acr]
    @admin_acr = params[:admin_acr]

    @current_institution = Institution.find(params[:id])
    
    if user_role_in?(:dmp_admin) 
      @institution_pool = Institution.order(full_name: :asc).where("id != ?", @current_institution.id).collect {|i| ["#{'-' * i.depth} #{i.full_name}", i.id] } 
    else
      @institution_pool = @current_institution.root.subtree.collect {|i| ["#{'-' * i.depth} #{i.full_name}", i.id] } 
      @institution_pool.delete_if {|i| i[1] == @current_institution.id}
    end

  end


  def create
    @current_institution = Institution.new(institution_params)
    respond_to do |format|  
      if @current_institution.save
        format.html { redirect_to edit_institution_path(@current_institution), notice: 'Institution was successfully created.' }
      else
        format.html { render new_institution_path}     
      end 
    end
  end

  # PATCH/PUT /institutions/1
  # PATCH/PUT /institutions/1.json
  def update
    @acr = params[:acr]
    @admin_acr = params[:admin_acr]
    @current_institution = Institution.find(params[:id])
    if user_role_in?(:dmp_admin) 
      @institution_pool = Institution.order(full_name: :asc).where("id != ?", @current_institution.id).collect {|i| ["#{'-' * i.depth} #{i.full_name}", i.id] } 
    else
      @institution_pool = @current_institution.root.subtree.collect {|i| ["#{'-' * i.depth} #{i.full_name}", i.id] } 
      @institution_pool.delete_if {|i| i[1] == @current_institution.id}
    end
    
    if (current_user.institution == @current_institution)
      respond_to do |format|  
        if @current_institution.update(institution_params)
          #format.html { redirect_to edit_institution_path(@current_institution), 
                        #notice: 'Institution was successfully updated.' }
          format.html { redirect_to institutions_path(@current_institution), 
                        notice: 'Institution was successfully updated.' }
        else
          format.html { render 'index'}     
        end 
      end
    else
      respond_to do |format|  
        if @current_institution.update(institution_params)
          format.html { redirect_to edit_institution_path(@current_institution), 
                        notice: 'Institution was successfully updated.' }
        else
          format.html { render 'edit'}     
        end 
      end
    end
  end


  # respond_to do |format|
  #     if @resource_context.update(to_save)
  #       format.html { redirect_to go_to, notice: message }
  #       format.json { head :no_content }
  #     else
  #       format.html { render 'edit'}
  #       format.json { head :no_content }
        
  #     end
  #   end

  # if @current_institution.update(institution_params)
    #   redirect_to edit_institution_path(@current_institution), notice: 'Institution was successfully updated.' 
    # else
    #   render edit_institution_path(@current_institution)
    #   # if params[:full_name].blank? || params[:full_name].nil?
    #   #   msg = "Please enter a name for the Institution."
    #   # else
    #   #   msg = "An error has occured and the institution cannot be updated."
    #   # end
    #   # flash[:error] = msg
    #   # redirect_to edit_institution_path(@current_institution)
    # end

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
    insts = ancestry_options(Institution.unscoped.arrange(order: :full_name)){|i| "#{'-' * i.depth} #{i.full_name}" }
    non_partner = insts.map{|i| i[1]}.index(0) #find non-partner institution, ie none of the above, always index 0
    if non_partner
      item = insts.delete_at(non_partner)
      item = ["Not in List", 0] # This institution is always renamed because we like it that way in the list
      insts.insert(0, item) #put it at the beginning of the list cause we like it that way
    end
    insts
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
    if user_role_in?(:dmp_admin)
      @users = User.where(id: @user_ids).order('created_at DESC').page(params[:page]).per(10)
    else
      @users = User.where(id: @user_ids, institution_id: [current_user.institution.subtree_ids]).order('created_at DESC').page(params[:page]).per(10)
    end
  end

  def partners_list
    @institutions = Institution.order(:full_name)
    if params[:all].blank? then
      unless params[:s].blank? || params[:e].blank?
        @institutions = @institutions.letter_range(params[:s], params[:e])
      end
      unless params[:q].blank? then
        @institutions = @institutions.search_terms(params[:q])
      end
      @institutions = @institutions.page(params[:page]).per(10)
    else
      @institutions = @institutions.page(0).per(9999)
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

  def users_in_any_role_for_any_institutions
    @user_ids = Authorization.pluck(:user_id) 
    @users = User.where(id: @user_ids)
  end

  def users_in_role_for_any_institutions(role_name)
    @user_ids = Authorization.pluck(:user_id)
    @users = User.joins({:authorizations => :role}).where("roles.name = ?", role_name)
  end

  def self.unique_plans
    joins(:requirements_templates, :plans).
    where(:requirements_templates => { :institution_id => self.subtree_ids }).
    group(:plan_id)
  end

end






