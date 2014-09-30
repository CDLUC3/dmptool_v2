class Api::V1::PlansController < Api::V1::BaseController
	before_action :authenticate

 	def index         
   	@public_plans = Plan.all.public_visibility
    @private_plans = Plan.all.private_visibility.joins(:users).where(user_plans: {owner: true}).where('users.id =?', current_user.id) 
    @institutional_plans = Plan.all.institutional_visibility.joins(:requirements_template).where('requirements_templates.institution_id =?', current_user.institution_id)
    @plans = @public_plans + @private_plans + @institutional_plans
    if from_date = params[:from_date]
      @plans = @plans.where(["created_at > ?", from_date])
    end
    render json: @plans, status: 200

 	end 

	def show
    @plan = Plan.find(params[:id])
    if (@plan.visibility == :public)  ||  
    		((@plan.visibility == :institutional) && (current_user.institution_id == @plan.requirements_template.institution_id))  
    	render json: @plan, status:200
    else
    	 render json: 'You are not authorized to look at this content', status: 401
    end 
  end


end