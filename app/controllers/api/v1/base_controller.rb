
# class Api::V1::BaseController < ActionController::Metal
#   include ActionController::Rendering        # enables rendering
#   include ActionController::MimeResponds     # enables serving different content types like :xml or :json
#   include AbstractController::Callbacks      # callbacks for your authentication logic
#   include ActionController::Renderers::All
 
#   append_view_path "#{Rails.root}/app/views/api/v1" # you have to specify your views location as well: THIS DOESN"T WORK
# end




class Api::V1::BaseController < ActionController::Base
	respond_to :json
end