class Api::V1::PlansController < Api::V1::BaseController
	
   include ApplicationHelper

   before_action :soft_authenticate
   #before_action :authenticate

    respond_to :json




 	def index
        if @user = User.find_by_id(session[:user_id])
           	@public_plans = Plan.all.public_visibility
            @private_plans = Plan.all.private_visibility.joins(:users).where(user_plans: {owner: true}).where('users.id =?', current_user.id) 
            @institutional_plans = Plan.all.institutional_visibility.joins(:requirements_template).where('requirements_templates.institution_id =?', current_user.institution_id)
            @plans = @public_plans + @private_plans + @institutional_plans
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
                @id = @plan.id
                @plan_responses = Response.where(plan_id: @id)
                if (@plan.visibility == :public)  ||  
                		((@plan.visibility == :institutional) && (current_user.institution_id == @plan.requirements_template.institution_id)) ||
                    ( (@plan.visibility == :private) && ( @plan.users.include?(current_user)) )
                	
                    @plan


                else
                	 render json: 'You are not authorized to look at this content.', status: 401
                end
            else
                render json: 'The plan you are looking for doesn\'t exist', status: 404
            end
        else
            if @plan = Plan.find_by_id(params[:id])
                @id = @plan.id
                @plan_responses = Response.where(plan_id: @id)
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

def single_response(plan_id, requirement_id)
    @response = Response.where(plan_id: plan_id, requirement_id: requirement_id).first
end


end