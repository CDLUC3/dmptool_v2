class GenericMailer < ActionMailer::Base
  default :from => APP_CONFIG['feedback_email_from']

  def contact_email(form_hash, addl_emails)
    # values :question_about, :name, :email, :message
    @form_hash = form_hash
    emails = APP_CONFIG['feedback_email_to'] + addl_emails
    mail :to => emails.join(","),
         :reply_to => form_hash[:email]
         :subject => 'DMPTool2 Contact Us Form Feedback',
         :from => APP_CONFIG['feedback_email_from']
         #:from => form_hash[:email]
  end

end