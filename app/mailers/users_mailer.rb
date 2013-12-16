class UsersMailer < ActionMailer::Base
  default :from => APP_CONFIG['feedback_email_from']

  def username_reminder(uid, email)
    @uid = uid
    @email = email
    mail :to => email,
         :subject => 'DMPTool username reminder',
         :from => APP_CONFIG['feedback_email_from']
  end

  def password_reset(uid, email, reset_path)
    @uid = uid
    @url = reset_path
    mail :to => email,
         :subject => 'DMPTool password reset',
         :from => APP_CONFIG['feedback_email_from']
  end

end