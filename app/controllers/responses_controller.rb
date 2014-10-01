class ResponsesController < ApplicationController
	before_action :set_response, only: [:show, :edit, :update, :destroy]

  # GET /responses
  # GET /responses.json
 def index
 	  @responses = Response.all
  end

  def new
  	@response = Response.new
  end

  def edit
  end

  def show
  end

  def create
  	@response = Response.new(response_params)
    @requirement_id = response_params[:requirement_id]
    @next_requirement_id = params[:next_requirement_id]
    @plan = Plan.find(response_params[:plan_id])
    @requirement = Requirement.find(@requirement_id)
    template_id = @plan.requirements_template_id
    @requirements_template = RequirementsTemplate.find(template_id)
    unless @requirements_template.nil?
      @requirements = @requirements_template.requirements
      @last_question = @requirements_template.last_question
    end
    respond_to do |format|    
      if ( !params[:save_and_next] && !params[:save_only]) && (@requirement.id == @last_question.id)
        if @response.save
          format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id) }
          format.json { render action: 'show', status: :created, location: @response }
        else
          format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id) }
          format.json { render json: @response.errors, status: :unprocessable_entity }
        end
      elsif (params[:save_and_next] || !params[:save_only]) && (@requirement.id == @last_question.id)
        

        if @response.save
          if @response.errors.any?
            format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id)  }
            format.json { render action: 'show', status: :created, location: @response }
          else
            format.html { redirect_to preview_plan_path(@plan) }
            format.json { render action: 'show', status: :created, location: @response }
          end
        else
          if @response.errors.any?
            format.html { redirect_to preview_plan_path(@plan) }
            format.json { render action: 'show', status: :created, location: @response }
          else
            format.html { redirect_to preview_plan_path(@plan) }
            format.json { render action: 'show', status: :created, location: @response }
          end
        end
        
      elsif (params[:save_and_next] || !params[:save_only])
        if @response.save
          format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id), notice: 'Response was successfully created.' }
          format.json { render action: 'show', status: :created, location: @response }
        else
          format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id) }
          format.json { render json: @response.errors, status: :unprocessable_entity }
        end

      else
        if @response.save
          format.html { redirect_to details_plan_path(@plan, requirement_id: @requirement_id), notice: 'Response was successfully created.' }
          format.json { render action: 'show', status: :created, location: @response }
        else
          format.html { redirect_to details_plan_path(@plan, requirement_id: @requirement_id) }
          format.json { render json: @response.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /responses/1
  # PATCH/PUT /responses/1.json
  def update
    respond_to do |format|
      @requirement_id = response_params[:requirement_id]
      @next_requirement_id = params[:next_requirement_id]
      @plan = Plan.find(response_params[:plan_id])
      @requirement = Requirement.find(@requirement_id)
      template_id = @plan.requirements_template_id
      @requirements_template = RequirementsTemplate.find(template_id)
      unless @requirements_template.nil?
        @requirements = @requirements_template.requirements
        @last_question = @requirements_template.last_question
      end 
      if ( !params[:save_and_next] && !params[:save_only]) && (@requirement.id == @last_question.id)
        if @response.update(response_params)
          format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id) }
          format.json { head :no_content }
        else
          redirect_to details_plan_path(@plan, requirement_id: @requirement_id)
          format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id) }
          format.json { render json: @response.errors, status: :unprocessable_entity }
        end
      elsif (params[:save_and_next] || !params[:save_only]) && (@requirement.id == @last_question.id)
        if @response.update(response_params)
          format.html { redirect_to preview_plan_path(@plan) }
          format.json { head :no_content }
        else
          format.html { redirect_to preview_plan_path(@plan) }
          format.json { head :no_content }
        end

      elsif (params[:save_and_next] || !params[:save_only])
        if @response.update(response_params)
          format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id), notice: 'Response was successfully created.' }
          format.json { render action: 'show', status: :created, location: @response }
        else
          format.html { redirect_to details_plan_path(@plan, requirement_id: @next_requirement_id) }
          format.json { render json: @response.errors, status: :unprocessable_entity }
        end

      else
        if @response.update(response_params)
          format.html { redirect_to details_plan_path(@plan, requirement_id: @requirement_id), notice: 'response was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to details_plan_path(@plan, requirement_id: @requirement_id) }
          format.json { render json: @response.errors, status: :unprocessable_entity }
        end
      end
    end

  rescue ActiveRecord::StaleObjectError
    #render :conflict_resolution_view
    flash[:error] = "This record changed while you were editing."
    redirect_to details_plan_path(@plan, requirement_id: @requirement_id)

  end

  # DELETE /responses/1
  # DELETE /responses/1.json
  def destroy
    plan_id = @response.plan_id
    @response.destroy
    respond_to do |format|
      format.html { redirect_to details_plan_path(plan_id) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response
      @response = Response.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_params
      params.require(:response).permit(:text_value, :numeric_value, :date_value, :enumeration_id, :plan_id, :requirement_id, :label_id, :lock_version, :current_user_id)
    end

    def set_values
      template_id = @plan.requirements_template_id
      @requirements_template = RequirementsTemplate.find(template_id)
      @requirements = @requirements_template.requirements
      @resource_contexts = ResourceContext.where(requirement_id: @requirement_id, institution_id: current_user.institution_id, requirements_template_id: @requirements_template.id)
    end
end

