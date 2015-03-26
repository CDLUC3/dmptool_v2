class Comment < ActiveRecord::Base

  include CommentEmail

  belongs_to :user
  belongs_to :plan

  validates_columns :visibility
  validates_columns :comment_type
  validates :user_id, presence: true, numericality: true
  validates :plan_id, presence: true, numericality: true
  validates :visibility, presence: true
  validates :value, presence: true

  scope :owner, -> { where(visibility: :owner) } #this oddly corresponds to the author of the comment
  scope :reviewer, -> { where(visibility: :reviewer) }

  scope :owner_comments, -> { where(comment_type: :owner) }
  scope :reviewer_comments, -> { where(comment_type: :reviewer) }

  def owner?
    visibility == :owner
    #comment_type == :owner
  end

  def reviewer?
    visibility == :reviewer
    #comment_type == :reviewer
  end

  def author_name
    user ? user.full_name : "anonymous"
  end


end
