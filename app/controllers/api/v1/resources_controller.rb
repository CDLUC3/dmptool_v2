class Api::V1::ResourcesController < Api::V1::BaseController

  respond_to :json

  def index
    @resources = Resource.all
  end

  def show
    @resource = Resource.find(params[:id])
  end

end

