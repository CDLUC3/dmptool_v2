class Api::V1::ResourcesController < Api::V1::BaseController

  def index
    respond_with(Resource.all)
  end

end