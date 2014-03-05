class Api::V1::PlansController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@plans = Plan.all     
  	end 

	def show
    	@plan = Plan.find(params[:id])
  	end


end