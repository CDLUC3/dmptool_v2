require 'htmltoword'
require 'pandoc-ruby'

class Api::V1::PlansController < Api::V1::BaseController

  include ApplicationHelper

  before_action :soft_authenticate
  #before_action :authenticate

  @@realm = "Plans"

  respond_to :json

  def index
    if @user = User.find_by_id(session[:user_id])
      if user_role_in?(:dmp_admin)
        #@plans = Plan.all
        @public_plans = Plan.all.public_visibility
        @institutional_plans = Plan.all.institutional_visibility
        @unit_plans = Plan.all.unit_visibility
        @private_plans = Plan.all.private_visibility
        @plans = @private_plans + @institutional_plans + @unit_plans + @public_plans

      elsif user_role_in?(:institutional_admin)
        @plans = inst_admin_plan_list
      else
        @public_plans = Plan.all.public_visibility

        @owned_private_plans = @user.owned_plans.private_visibility
        @coowned_private_plans = @user.coowned_plans.private_visibility

        # @institutional_plans = Plan.institutional_visibility.joins( {:users => :institution} ).where("user_plans.owner = 1").where("users.institution_id IN (?)", @user.institution.root.subtree_ids)
        # @unit_plans = Plan.unit_visibility.joins( {:users => :institution} ).where("user_plans.owner = 1").where("users.institution_id IN (?)", @user.institution.subtree_ids)


        @institutional_plans = Plan.institutional_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id IN (?)", @user.institution.root.subtree_ids)
        @unit_plans = Plan.unit_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id IN (?)", @user.institution.subtree_ids)

        @institutional_coowned_plans = @user.coowned_plans.institutional_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id NOT IN (?)", @user.institution.root.subtree_ids)
        @unit_coowned_plans = @user.coowned_plans.unit_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id NOT IN (?)", @user.institution.root.subtree_ids)

        @plans = @public_plans + @owned_private_plans + @coowned_private_plans + @institutional_plans + @unit_plans + @institutional_coowned_plans + @unit_coowned_plans
      end
      if from_date = params[:from_date]
        @plans = @plans.where(["created_at > ?", from_date])
      end
    else
      @plans = Plan.all.public_visibility
    end
    @plans.uniq!
  end


  def show
    if @user = User.find_by_id(session[:user_id])
      if @plan = Plan.find_by_id(params[:id])
        if user_role_in?(:dmp_admin)
          @plan
        else
          @id = @plan.id
          if (@plan.visibility == :public) ||
              ((@plan.visibility == :institutional) && (@user.institution.root.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(@user))) ||
              ((@plan.visibility == :unit) && (@user.institution.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(@user))) ||
              ((@plan.visibility == :private) && (@user == @plan.owner || @plan.coowners.include?(@user)))
            @plan
          else
            render_unauthorized
          end
        end
      else
        render_not_found
      end
    else
      if @plan = Plan.find_by_id(params[:id])
        @id = @plan.id
        if (@plan.visibility == :public)
          @plan
        else
          render_unauthorized
        end
      else
        render_not_found
      end
    end
  end


  def plans_full_show
    if @user = User.find_by_id(session[:user_id])
      if @plan = Plan.find_by_id(params[:id])
        if user_role_in?(:dmp_admin)
          @plan
        else
          @id = @plan.id
          if (@plan.visibility == :public) ||
              ((@plan.visibility == :institutional) && (@user.institution.root.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(@user))) ||
              ((@plan.visibility == :unit) && (@user.institution.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(@user))) ||
              ((@plan.visibility == :private) && (@user == @plan.owner || @plan.coowners.include?(@user)))
            @plan
          else
            render_unauthorized
          end
        end
      else
        render_not_found
      end
    else
      if @plan = Plan.find_by_id(params[:id])
        @id = @plan.id
        if (@plan.visibility != :public)
          @plan
        else
          render_unauthorized
        end
      else
        render_not_found
      end
    end
    
    respond_to do |format|
      format.json do
        render :layout => false
      end
      format.pdf do
        render :layout => false, :template => '/plans/show.pdf.ruby'
      end
      format.rtf do
        render :layout => false, :template => '/plans/show.rtf.ruby'
      end
      format.docx do
        templ_path = File.join(Rails.root.to_s, 'public')
        str = render_to_string(:template => '/api/v1/plans/plans_full_show_docx.html.erb', :layout => false)
        converter = PandocRuby.new(str, :from => :html, :to => :docx, 'data-dir' => templ_path )
        headers["Content-Disposition"] = "attachment; filename=\"" + sanitize_for_filename(@plan.name) + ".docx\""
        render :text => converter.convert, :content_type=> 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      end
    end
  end


  def plans_full_index
    if @user = User.find_by_id(session[:user_id])
      if user_role_in?(:dmp_admin)
        @plans = Plan.all
      elsif user_role_in?(:institutional_admin)
        @plans = inst_admin_plan_list
      else
        @public_plans = Plan.all.public_visibility

        @owned_private_plans = @user.owned_plans.private_visibility
        @coowned_private_plans = @user.coowned_plans.private_visibility

        @institutional_plans = Plan.institutional_visibility.joins({:users => :institution}).where("user_plans.owner = 1").where("users.institution_id IN (?)", @user.institution.root.subtree_ids)
        @unit_plans = Plan.unit_visibility.joins({:users => :institution}).where("user_plans.owner = 1").where("users.institution_id IN (?)", @user.institution.subtree_ids)

        @plans = @public_plans + @owned_private_plans + @coowned_private_plans + @institutional_plans + @unit_plans
      end
      if from_date = params[:from_date]
        @plans = @plans.where(["created_at > ?", from_date])
      end
    else
      @plans = Plan.all.public_visibility
    end
    @plans.uniq!
  end

  def plans_owned
    if @user = User.find_by_id(session[:user_id])
      @plans = owned_plan_list
    end
  end

  def plans_owned_full
    if @user = User.find_by_id(session[:user_id])
      @plans = owned_plan_list
    end
  end

  # ------------------------------------------------------------------------------------
  # Returns all templates 'used' by the user's institution
  def plans_templates_index
    @user = User.find_by_id(session[:user_id])
    
    # If an institutional user, return the templates that the instition has used to make plans
    if user_role_in?(:dmp_admin)
      @plans = Plan.includes(:requirements_template).order(id: :asc)
      
      @plans
      
    elsif user_role_in?(:institutional_admin, :institutional_reviewer, :resource_editor, :template_editor)
      @plans = Plan.joins(:users).where("users.institution_id IN (?)", @user.institution.id).
                            includes(:requirements_template).order(id: :asc)
      @plans
    else
      render_unauthorized
    end
  end

  # ------------------------------------------------------------------------------------
  # Returns the template 'used' by the specified plan
  def plans_templates_show
    @user = User.find_by_id(session[:user_id])
    
    # If an institutional user, return the template 
    if user_role_in?(:dmp_admin)
      @plan = Plan.find_by_id(params[:id])
      
      @plan
    elsif user_role_in?(:institutional_admin, :institutional_reviewer, :resource_editor, :template_editor)
      @plan = Plan.joins(:users).where("users.institution_id IN (?)", @user.institution.id).find_by_id(params[:id])

      # User does not have access to the requested plan
      if @plan.nil?
        render_unauthorized
      else
        @plan
      end
    else
      render_unauthorized
    end
  end

  # ------------------------------------------------------------------------------------
  private
  def inst_admin_plan_list
    @institutional_plans = Plan.institutional_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id IN (?)", @user.institution.root.subtree_ids)
    @unit_plans = Plan.unit_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id IN (?)", @user.institution.subtree_ids)
    @public_inst_plans = Plan.public_visibility.joins(:users).where("users.institution_id IN (?)", @user.institution.subtree_ids)
    @personal_plans = Plan.private_visibility.joins(:users).where("users.id = ?", @user.id )
    return @institutional_plans + @unit_plans + @public_inst_plans + @personal_plans
  end

  def owned_plan_list
    Plan.joins(:users).where(user_plans: {owner: true}).where("users.id = ?", @user.id )
  end


end
