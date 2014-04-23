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

  #pass in the email addresses, the email subject and the template name that has the text

  #an example call:
  # UsersMailer.notification(['catdog@mailinator.com', 'dogdog@mailinator.com'],
  #                           'that frosty mug taste', 'test_mail').deliver
  def notification(email_address, subject, message_template, locals)
    if email_address.class == Array
      email_address_array = email_address
    else
      email_address_array = [email_address]
    end
    @vars = locals
    mail( :to             => email_address_array.join(','),
          :subject        => "[DMPTool] #{subject}",
          :from           => APP_CONFIG['feedback_email_from'],
          :reply_to       => APP_CONFIG['feedback_email_from'],
          :template_name  => message_template
    )
  end

end