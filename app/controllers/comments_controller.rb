class CommentsController < ApplicationController

  before_action :require_login
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  # GET /comments
  # GET /comments.json
 def index
 	  @comments = Comment.all
  end

  def new
  	@comment = Comment.new
    comments = Comment.where(plan_id: @plan_id)
    @reviewer_comments = comments.reviewer_comments.order('created_at DESC')
    @owner_comments = comments.owner_comments.order('created_at DESC')
  end

  def edit
    @plan_id = comment_params[:plan_id]
    comments = Comment.where(plan_id: @plan_id)
    @reviewer_comments = comments.reviewer_comments.order('created_at DESC')
    @owner_comments = comments.owner_comments.order('created_at DESC')
  end

  def create
    @comment = Comment.new(comment_params)
    @plan_id = comment_params[:plan_id]
    comments = Comment.where(plan_id: @plan_id)
    @reviewer_comments = comments.reviewer_comments.order('created_at DESC')
    @owner_comments = comments.owner_comments.order('created_at DESC')
    respond_to do |format|
      if @comment.save
        format.html { redirect_to comments_path, notice: 'comment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @comment }
        format.js
      else
        format.html { render action: 'new' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    @plan_id = comment_params[:plan_id]
    comments = Comment.where(plan_id: @plan_id)
    @reviewer_comments = comments.reviewer_comments.order('created_at DESC')
    @owner_comments = comments.owner_comments.order('created_at DESC')
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to comments_path, notice: 'comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    plan_id = @comment.plan_id
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:value, :user_id, :comment_id, :plan_id, :visibility, :comment_type)
    end
end
