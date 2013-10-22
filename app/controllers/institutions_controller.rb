class InstitutionsController < ApplicationController
  before_action :set_institution, only: [:show, :edit, :update, :destroy]
  before_action :check_for_cancel, :update => [:create, :update, :destroy]

  # GET /institutions
  # GET /institutions.json
  def index
    @institutions = Institution.all
    #@institution = Institution.new
     
    @current_user = User.find(3)
    @current_institution = Institution.find(2)
    @institution_users = @current_institution.users
  end

  # GET /institutions/1
  # GET /institutions/1.json
  def show
  end

  # GET /institutions/new
  def new
    @institution = Institution.new
  end

  # GET /institutions/1/edit
  def edit
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_institution
      @institution = Institution.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def institution_params
      params.require(:institution).permit(:full_name, :nickname, :desc, :contact_info, :contact_email, :url, :url_text, :shib_entity_id, :shib_domain)
    end

    def check_for_cancel
      redirect_to :back if params[:commit] == "Cancel"
    end

end






