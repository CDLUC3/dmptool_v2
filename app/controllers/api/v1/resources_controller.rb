class Api::V1::ResourcesController < Api::V1::BaseController

  # def index
  #   respond_with(Resource.all)
  # end

  def index
    @resources = Resource.all
    respond_to do |format|
      format.json { render :json => @resources }
    end
  end


end