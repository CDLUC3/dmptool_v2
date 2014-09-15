class Api::V1::PlansController < Api::V1::BaseController


 	def index         
   	@plans = Plan.all 

   	# respond_to do |format|
   	# 	format.json {render json: @plans, status: 200}
   	# 	format.xml {render xml: @plans, status: 200}
   	# end

    render json: @plans, status: 200

 	end 

	def show
    @plan = Plan.find(params[:id])

    # respond_to do |format|
    #  	format.json {render json: @plan, status: 200}
    #  	format.xml {render xml: @plan, status: 200}
    # end

    render json: @plan, status:200
  end


end