# Test ActionMailer during development with in-browser emails in new tab.
# in environments/development.rb: config.action_mailer.delivery_method = :letter_opener

#FIXME use stugov server smtp settings, or hide this password
ActionMailer::Base.smtp_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :user_name            => SETTINGS[:email_login],  
  :password             => SETTINGS[:email_password],
  :authentication       => "plain",  
  :enable_starttls_auto => true  
}