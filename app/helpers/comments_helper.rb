module CommentsHelper
	def user_name(comment)
		user_id = comment.user_id
		user_name = User.find(user_id).full_name
	end
end
