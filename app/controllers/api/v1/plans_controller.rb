class Api::V1::PlansController < Api::V1::BaseController

  include ApplicationHelper

  before_action :soft_authenticate

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
        @institutional_plans = Plan.institutional_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id IN (?)", @user.institution.root.subtree_ids)
        @unit_plans = Plan.unit_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id IN (?)", @user.institution.subtree_ids)
        @plans = @institutional_plans + @unit_plans
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
    @plans
  end


  def show
    if @user = User.find_by_id(session[:user_id])
      if @plan = Plan.find_by_id(params[:id])
        if user_role_in?(:dmp_admin)
          @plan
        else         
          if (@plan.visibility == :public) ||
              ((@plan.visibility == :institutional) && (@user.institution.root.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(@user))) ||
              ((@plan.visibility == :unit) && (@user.institution.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(@user))) ||
              ((@plan.visibility == :private) && (@user == @plan.owner || @plan.coowners.include?(@user)))
            @plan
          else
            render json: 'You are not authorized to look at this content.', status: 401
          end
        end
      else
        render json: 'The plan you are looking for doesn\'t exist', status: 404
      end
    else
      if @plan = Plan.find_by_id(params[:id])
        @id = @plan.id
        if (@plan.visibility == :public)
          @plan
        else
          render json: 'You are not authorized to look at this content.', status: 401
        end
      else
        render json: 'The plan you are looking for doesn\'t exist', status: 404
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
            render json: 'You are not authorized to look at this content.', status: 401
          end
        end
      else
        render json: 'The plan you are looking for doesn\'t exist', status: 404
      end
    else
      if @plan = Plan.find_by_id(params[:id])
        @id = @plan.id
        if (@plan.visibility == :public)
          @plan
        else
          render json: 'You are not authorized to look at this content.', status: 401
        end
      else
        render json: 'The plan you are looking for doesn\'t exist', status: 404
      end
    end
  end


  def plans_full_index
    if @user = User.find_by_id(session[:user_id])
      if user_role_in?(:dmp_admin)
        @plans = Plan.all
      elsif user_role_in?(:institutional_admin)
        @institutional_plans = Plan.institutional_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id IN (?)", @user.institution.root.subtree_ids)
        @unit_plans = Plan.unit_visibility.joins(:users).where(user_plans: {owner: true}).where("users.institution_id IN (?)", @user.institution.subtree_ids)
        @plans = @institutional_plans + @unit_plans
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
    @plans
  end

  # ------------------------------------------------------------------------------------
  # Returns all templates 'used' by the user's institution
  def templates_index
    @user = User.find_by_id(session[:user_id])
    
    # If an institutional user, return the templates that the instition has used to make plans
    if user_role_in?(:institutional_admin, :institutional_reviewer, :resource_editor, :template_editor)
      @plans = Plan.joins(:users).where("users.institution_id IN (?)", @user.institution.id).
                            includes(:requirements_template).order(id: :asc)
      @plans
    else
      render_unauthorized
    end
  end

  # ------------------------------------------------------------------------------------
  # Returns the template 'used' by the specified plan
  def templates_show
    @user = User.find_by_id(session[:user_id])
    
    # If an institutional user, return the template 
    if user_role_in?(:institutional_admin, :institutional_reviewer, :resource_editor, :template_editor)
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
end
