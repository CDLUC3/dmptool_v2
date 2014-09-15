class Api::V1::PlansController < Api::V1::BaseController


 	def index         
   	@plans = Plan.all 

    if from_date = params[:from_date]
      @plans = @plans.where(["created_at > ?", from_date])
    end

    render json: @plans, status: 200

 	end 

	def show
    @plan = Plan.find(params[:id])

    render json: @plan, status:200
  end


end