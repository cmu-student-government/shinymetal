# Test ActionMailer during development with in-browser emails in new tab.
# in environments/development.rb: config.action_mailer.delivery_method = :letter_opener
# FIXME This will be implemented for production
# ActionMailer::Base.smtp_settings = {  
#   :address              => "smtp.gmail.com",  
#   :port                 => 587,  
#   :user_name            => "<your username>",  
#   :password             => "<your password>",  
#   :authentication       => "plain",  
#   :enable_starttls_auto => true  
# }