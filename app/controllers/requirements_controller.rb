class RequirementsController < ApplicationController

  before_action :require_login
  before_filter :get_requirements_template, except: [:reorder]
  before_action :set_requirement, only: [:show, :edit, :update, :destroy]

  # GET /requirements
  # GET /requirements.json
  def index
    @requirement = @requirements_template.requirements.build
    @requirement.requirements_template.ensure_requirements_position # be sure that position is set for these items, if not, set defaults
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
    @requirement.enumerations.build
    render 'index'
  end

  # GET /requirements/1/edit
  def edit
    @requirements = @requirements_template.requirements
    @enumerations = @requirement.enumerations
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

  # reorders the requirements in a template from drag and drop
  def reorder
    respond_to do |format|
      format.js do
        render nothing: true && return if params[:drag_id].blank? || params[:drop_id].blank?
        @drag_req = Requirement.find(params[:drag_id].first)
        if params[:drop_id] == 'drop_before_first' #a special case of dropping before -- the rest are dropping after
          desc_ids = @drag_req.descendant_ids
          old_path = (@drag_req.ancestry.nil? ? [] : @drag_req.ancestry.split("/")) + [@drag_req.id]
          @drop_req = @drag_req.requirements_template.requirements.roots.order(:position).first
          @drag_req.position_before(@drop_req.id)
          @drag_req.update_column(:ancestry, nil)
          if @drag_req.group
            fix_descendant_ancestry(desc_ids, old_path, [@drag_req.id])
          end
        else
          @drop_req = Requirement.find(params[:drop_id].first)
          render nothing: true && return if @drag_req.requirements_template_id != @drag_req.requirements_template_id
          # add other validation that you can reorder here

          if @drag_req.group.blank? && @drop_req.group.blank? # one requirement dropped on another requirement
            #unless @drop_req.ancestor_ids.include?(@drag_req.id) #do not change anything for dragging yourself into your own area
            @drag_req.position_after(@drop_req.id)
            @drag_req.update_column(:ancestry, @drop_req.ancestry)
            #end
          elsif @drag_req.group.blank? && @drop_req.group #one requirement dropped on a folder
            @drag_req.position_after(@drop_req.id)
            a = (@drop_req.ancestry.nil? ? [] : @drop_req.ancestry.split("/"))
            a = (a + [@drop_req.id]).join("/")
            @drag_req.update_column(:ancestry, a)

          elsif @drag_req.group && @drop_req.group #dropping on a folder on a folder
            unless @drop_req.ancestor_ids.include?(@drag_req.id) #do not change anything for dragging yourself into your own area
              desc_ids = @drag_req.descendant_ids
              old_path = (@drag_req.ancestry.nil? ? [] : @drag_req.ancestry.split("/")) + [@drag_req.id]
              new_path = (@drop_req.ancestry.nil? ? [] : @drop_req.ancestry.split("/")) + [@drop_req.id]
              @drag_req.position_after(@drop_req.id)
              @drag_req.update_column(:ancestry, new_path.join("/")) #put it under the dropped folder
              new_path = new_path + [@drag_req.id]
              fix_descendant_ancestry(desc_ids, old_path, new_path)
            end
          elsif @drag_req.group && @drop_req.group.blank? #dropping on a folder on a file
            unless @drop_req.ancestor_ids.include?(@drag_req.id) #do not change anything for dragging yourself into your own area
              desc_ids = @drag_req.descendant_ids
              old_path = (@drag_req.ancestry.nil? ? [] : @drag_req.ancestry.split("/")) + [@drag_req.id]
              new_path = (@drop_req.ancestry.nil? ? [] : @drop_req.ancestry.split("/"))
              @drag_req.position_after(@drop_req.id)
              @drag_req.update_column(:ancestry, @drop_req.ancestry) #put it under same parent
              new_path = new_path + [@drag_req.id]
              fix_descendant_ancestry(desc_ids, old_path, new_path)
            end
          end
        end

        #these need setting for re-rendering the view area
        @requirements_template = @drag_req.requirements_template
        @requirements = @requirements_template.requirements
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_requirement
      @requirement = @requirements_template.requirements.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def requirement_params
      params.require(:requirement).permit(:position, :text_brief, :text_full, :requirement_type, :obligation, :default, :requirements_template_id, :parent_id, :group, enumerations_attributes: [:id, :requirement_id, :value])
    end

    # Fetch the corresponding Requirements Template
    def get_requirements_template
      @requirements_template =  RequirementsTemplate.find(params[:requirements_template_id])
    end

    #this is needed because the ancestry gem refuses to work, perhaps because of validations or other
    #problems and we really shouldn't need to update the timestamps for reordering, either
    def fix_descendant_ancestry(desc_ids, old_path, new_path)
      cut = old_path.length
      desc_ids.each do |i|
        r = Requirement.find(i)
        path = r.ancestry.split("/")
        a = (new_path + path[cut..-1]).join("/")
        r.update_column(:ancestry, a)
      end
    end
end
