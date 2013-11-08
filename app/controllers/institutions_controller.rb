class InstitutionsController < ApplicationController
  before_action :set_institution, only: [:show, :edit, :update, :destroy]
  before_action :check_for_cancel, :update => [:create, :update, :destroy]
  before_filter :populate_institution_select_list
  
  
  

  # GET /institutions
  # GET /institutions.json
  def index
    @institutions = Institution.all
    @institution = Institution.new(:parent_id => params[:parent_id])

    @current_user = current_user
    @institution = @current_user.institution
    @institution_users = @institution.users
    
    @categories.delete_if {|i| i[1] == @institution.id}

  end

  # GET /institutions/1
  # GET /institutions/1.json
  def show
  end

  # GET /institutions/new
  def new
    @institution = Institution.new(:parent_id => params[:parent_id])
  end

  # GET /institutions/1/edit
  def edit
    @institution = Institution.find(params[:id])
  end

  # POST /institutions
  # POST /institutions.json
  def create
    @institution = Institution.new(institution_params)

    respond_to do |format|
      if @institution.save
        format.html { redirect_to @institution, notice: 'Institution was successfully created.' }
        format.json { render action: 'show', status: :created, location: @institution }
      else
        format.html { render action: 'new' }
        format.json { render json: @institution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /institutions/1
  # PATCH/PUT /institutions/1.json
  def update
    respond_to do |format|
      if @institution.update(institution_params)
        format.html { redirect_to @institution, notice: 'Institution was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @institution.errors, status: :unprocessable_entity }
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


  def add_authorization
    emails = params[:email].split(/,\s*/) unless params[:email] == ""
    @role_id = params[:role_id]
    @role_name = Role.where(role_id: @role_id).pluck(:name)
    @invalid_emails = []
    @existing_emails = []
    emails.each do |email|
      @user = User.find_by(email: email)
      if @user.nil?
        @invalid_emails << email
      else
        begin
          authorization = Authorization.create(role_id: @role_id, user_id: @user.id)
          authorization.save!
        rescue ActiveRecord::RecordNotUnique
          @existing_emails << email
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
        flash.now[:notice] = "Added #{@role_name} Role to the Users specified."
        format.js { render action: 'add_authorization' }
      end
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






