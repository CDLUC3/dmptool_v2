class Api::V1::ProjectsController < Api::V1::BaseController

  def index
    respond_with(User.all)
  end

end