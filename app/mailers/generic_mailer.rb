class GenericMailer < ActionMailer::Base

  def contact_email(form_hash, addl_emails)
    # values :question_about, :name, :email, :message
    @form_hash = form_hash
    emails = APP_CONFIG['feedback_email_to'] + addl_emails
    mail :to => emails.join(","),
         :subject => 'DMPTool2 Contact Us Form Feedback',
         :from => APP_CONFIG['feedback_email_from']
         #:from => form_hash[:email]
  end

end