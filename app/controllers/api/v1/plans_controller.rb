class Api::V1::PlansController < Api::V1::BaseController
	before_action :authenticate

 	def index         
   	@plans = Plan.all.public_visibility 
    if from_date = params[:from_date]
      @plans = @plans.where(["created_at > ?", from_date])
    end
    render json: @plans, status: 200

 	end 

	def show
    @plan = Plan.find(params[:id])
    if 	@plan.visibility == :public
    	render json: @plan, status:200
    else
    	 render json: 'You are not authorized to look at this content', status: 401
    end 
  end


end