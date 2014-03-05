class Api::V1::CommentsController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@comments = Comment.all     
  	end 

	def show
    	@comment = Comment.find(params[:id])
  	end


end