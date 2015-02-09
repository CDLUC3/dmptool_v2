class Api::V1::PlansController < Api::V1::BaseController
	
   include ApplicationHelper

   before_action :soft_authenticate
   #before_action :authenticate

    respond_to :json


 	def index

        if @user = User.find_by_id(session[:user_id])
            if user_role_in?(:dmp_admin)
                @plans = Plan.all
            else
               	@public_plans = Plan.all.public_visibility
                
                @owned_private_plans = @user.owned_plans.private_visibility
                @coowned_private_plans = @user.coowned_plans.private_visibility

                @institutional_plans = Plan.institutional_visibility.joins( {:users => :institution} ).where("user_plans.owner = 1").where("users.institution_id IN (?)", @user.institution.root.subtree_ids)
                @unit_plans = Plan.unit_visibility.joins( {:users => :institution} ).where("user_plans.owner = 1").where("users.institution_id IN (?)", @user.institution.subtree_ids)

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


	def show
        if @user = User.find_by_id(session[:user_id])
            if @plan = Plan.find_by_id(params[:id])
                if user_role_in?(:dmp_admin)
                    @plan
                else
                    @id = @plan.id

                    if (@plan.visibility == :public)  ||  
                        ( (@plan.visibility == :institutional) && ( @user.institution.root.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(@user)  ) ) ||
                        ( (@plan.visibility == :unit) && ( @user.institution.subtree_ids.include?(@plan.owner.institution_id) || @plan.coowners.include?(@user)  ) ) ||
                        ( (@plan.visibility == :private) && ( @user == @plan.owner || @plan.coowners.include?(@user)) )
                    	
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


end