class Api::V1::SamplePlansController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@sample_plans = SamplePlan.all     
  	end 

	def show
    	@sample_plan = SamplePlan.find(params[:id])
  	end


end