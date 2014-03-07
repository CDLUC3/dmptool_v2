class Api::V1::InstitutionsController < Api::V1::BaseController

	respond_to :json

	def index         
  	@institutions = Institution.all     
	end 

	def show
    	@institution = Institution.find(params[:id])
    	#@plans = @institution.unique_plans
    	@plans = @institution.id
    	@status = "ok"
  end


	def self.unique_plans
    joins(:requirements_templates, :plans).
    where(:requirements_templates => { :institution_id => self.subtree_ids }).
    group(:requirement_id)
 	end

end




# controller:

# @cars = Car.all
# @status = "ok"

# view:

# object false
# child(@cars) { attributes :car_name, :car_make }
# node(:status) { @status }


#node(:plans) { @plans }