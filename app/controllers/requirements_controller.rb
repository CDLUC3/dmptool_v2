class RequirementsController < ApplicationController
  before_filter :get_requirements_template
  before_action :set_requirement, only: [:show, :edit, :update, :destroy]

  # GET /requirements
  # GET /requirements.json
  def index
    @requirement = @requirements_template.requirements.build
    @requirements = @requirements_template.requirements
  end

  # GET /requirements/1
  # GET /requirements/1.json
  def show
  end

  # GET /requirements/new
  def new
    @requirement = @requirements_template.requirements.build(:parent_id => params[:parent_id])
    @requirements = @requirements_template.requirements
    render 'index'
  end

  # GET /requirements/1/edit
  def edit
    @requirements = @requirements_template.requirements
    render 'index'
  end

  # POST /requirements
  # POST /requirements.json
  def create
    @requirement =  @requirements_template.requirements.build(requirement_params)
    @requirements = @requirements_template.requirements
    respond_to do |format|
      if @requirement.save
        format.html { redirect_to requirements_template_requirements_path(@requirements_template), notice: 'Requirement was successfully created.' }
        format.json { render action: 'show', status: :created, location: @requirement }
      else
        format.html { render action: 'index' }
        format.json { render json: @requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requirements/1
  # PATCH/PUT /requirements/1.json
  def update
    @requirements = @requirements_template.requirements
    respond_to do |format|
      if @requirement.update(requirement_params)
        format.html { redirect_to requirements_template_requirements_path(@requirements_template), notice: 'Requirement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'index' }
        format.json { render json: @requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requirements/1
  # DELETE /requirements/1.json
  def destroy
    @requirements = @requirements_template.requirements
    @requirement.destroy
    respond_to do |format|
      format.html { redirect_to requirements_template_requirements_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_requirement
      @requirement = @requirements_template.requirements.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def requirement_params
      params.require(:requirement).permit(:order, :text_brief, :text_full, :requirement_type, :obligation, :default, :requirements_template_id, :parent_id, :group, enumerations_attributes: [:id, :requirement_id, :value])
    end

    # Fetch the corresponding Requirements Template
    def get_requirements_template
      @requirements_template =  RequirementsTemplate.find(params[:requirements_template_id])
    end
end
