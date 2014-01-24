class GenericMailer < ActionMailer::Base
  default :from => APP_CONFIG['feedback_email_from']

  def contact_email(form_hash, email)
    # values :question_about, :name, :email, :message
    @form_hash = form_hash
    mail :to => email,
         :reply_to => form_hash[:email],
         :subject => 'DMPTool2 Contact Us Form Feedback',
         :from => APP_CONFIG['feedback_email_from']
  end

end