class GenericMailer < ActionMailer::Base

  def contact_email(form_hash)
    # values :question_about, :name, :email, :message
    @form_hash = form_hash
    mail :to => APP_CONFIG['feedback_email_to'],
         :subject => 'DMPTool2 Contact Us Form Feedback',
         :from => form_hash[:email]
  end

end