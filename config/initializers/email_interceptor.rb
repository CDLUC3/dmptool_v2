class EmailInterceptor
  # Intercepts outgoing emails and changes the recipient to the developers
  def self.delivering_email(message)
    message.to = ['brian.riley@ucop.edu']
  end
end

if Rails.env.development? or Rails.env.test?
  ActionMailer::Base.register_interceptor(EmailInterceptor)
end
