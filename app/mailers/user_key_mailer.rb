class UserKeyMailer < ApplicationMailer
  def submitted_msg(user)
    @user = user
    # This will not send any real email in development mode.
    # Instead, the email will be opened in browser.
    email = "#{@current_user.andrew_id}@andrew.cmu.edu"
    mail(:to => email,
         :subject => "Shiny Metal API Notice: Key Submitted")
  end

  def expiry_warning_msg(user, user_key)
  	@user = user
  	@user_key = user_key
    email = "#{@user.andrew_id}@andrew.cmu.edu"
    mail(:to => email,
         :subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Will Expire Soon")
  end

  def expiry_msg(user, user_key)
  	@user = user
  	@user_key = user_key
    email = "#{@user.andrew_id}@andrew.cmu.edu"
    mail(:to => email,
         :subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Has Expired")
  end

  def app_reset_msg(user, user_key)
  	@user = user
  	@user_key = user_key
  	email = "#{@user.andrew_id}@andrew.cmu.edu"
  	mail(:to => email, 
  		:subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Application Has Been Reopened")
  end

end
