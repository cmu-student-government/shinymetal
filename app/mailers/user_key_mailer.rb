class UserKeyMailer < ApplicationMailer
  # FIXME make sure to replace with the actual URL when deployed
  default_url_options[:host] = 'stugov.andrew.cmu.edu/shinymetal'

  def submitted_msg(user)
    @recipient = user
    # This will not send any real email in development mode.
    # Instead, the email will be opened in browser.
    email = "#{@recipient.andrew_id}@andrew.cmu.edu"
    mail(:to => email,
         :subject => "Shiny Metal API Notice: Key Request Submitted")
  end

  def admin_submit_msg(admin, user, user_key)
    @recipient = admin
    @user = user
    @user_key = user_key
    email = "#{@recipient.andrew_id}@andrew.cmu.edu"
    mail(:to => email,
         :subject => "Shiny Metal API Notice: Key Request Submitted")
  end

  def share_with_approver_msg(user, user_key)
    @user = user
    @user_key = user_key
#FIXME test in production, letter opener doesn't seem to play nicely with Proc.new, i think it works tho ?
    email = Proc.new { User.approvers_only.pluck(:andrew_id).map { |a| a+"@andrew.cmu.edu"} }
    mail(:to => email, 
         :subject => "Shiny Metal API Notice: Key Request Available For Approval")
  end

  def expiry_warning_msg(user, user_key)
  	@recipient = user
  	@user_key = user_key
    email = "#{@recipient.andrew_id}@andrew.cmu.edu"
    mail(:to => email,
         :subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Will Expire Soon")
  end

  def expiry_msg(user, user_key)
  	@recipient = user
  	@user_key = user_key
    email = "#{@recipient.andrew_id}@andrew.cmu.edu"
    mail(:to => email,
         :subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Has Expired")
  end

  def app_reset_msg(user, user_key)
  	@recipient = user
  	@user_key = user_key
  	email = "#{@recipient.andrew_id}@andrew.cmu.edu"
  	mail(:to => email, 
  		:subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Application Has Been Reopened")
  end

end
