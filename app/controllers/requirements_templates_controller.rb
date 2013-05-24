class RequirementsTemplatesController < ApplicationController
  before_action :set_requirements_template, only: [:show, :edit, :update, :destroy]

  # GET /requirements_templates
  # GET /requirements_templates.json
  def index
    @requirements_templates = RequirementsTemplate.all
  end

  # GET /requirements_templates/1
  # GET /requirements_templates/1.json
  def show
  end

  # GET /requirements_templates/new
  def new
    @requirements_template = RequirementsTemplate.new
  end

  # GET /requirements_templates/1/edit
  def edit
  end

  # POST /requirements_templates
  # POST /requirements_templates.json
  def create
    @requirements_template = RequirementsTemplate.new(requirements_template_params)

    respond_to do |format|
      if @requirements_template.save
        format.html { redirect_to @requirements_template, notice: 'Requirements template was successfully created.' }
        format.json { render action: 'show', status: :created, location: @requirements_template }
      else
        format.html { render action: 'new' }
        format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requirements_templates/1
  # PATCH/PUT /requirements_templates/1.json
  def update
    respond_to do |format|
      if @requirements_template.update(requirements_template_params)
        format.html { redirect_to @requirements_template, notice: 'Requirements template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @requirements_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requirements_templates/1
  # DELETE /requirements_templates/1.json
  def destroy
    @requirements_template.destroy
    respond_to do |format|
      format.html { redirect_to requirements_templates_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_requirements_template
      @requirements_template = RequirementsTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def requirements_template_params
      params.require(:requirements_template).permit(:institution_id, :name, :active, :start_date, :end_date, :visibility, :version, :parent_id, :mandatory_review)
    end
end
