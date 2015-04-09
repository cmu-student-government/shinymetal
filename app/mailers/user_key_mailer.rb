class UserKeyMailer < ApplicationMailer
  # FIXME make sure to replace with the actual URL when deployed
  default_url_options[:host] = 'stugov.andrew.cmu.edu/shinymetal'

  # This will not send any real email in development mode.
  # Instead, email will be opened in browser.

  #email for user when they submit an application
  def submitted_msg(user)
    @recipient = user
    mail(:to => @recipient.email,
         :subject => "Shiny Metal API Notice: Key Request Submitted")
  end

  #email for admin when an application has been submitted
  def admin_submit_msg(admin, user, user_key)
    @recipient = admin
    @user = user
    @user_key = user_key
    mail(:to => @recipient.email,
         :subject => "Shiny Metal API Notice: Key Request Submitted")
  end

  #email for approvers when a key has been marked ready for approval
  def share_with_approver_msg(user, user_key)
    @user = user
    @user_key = user_key
    #FIXME test in production, letter opener doesn't seem to play nicely with Proc.new, i think it works tho ?
    email = Proc.new { User.approvers_only.map { |a| a.email }
    mail(:to => email, 
         :subject => "Shiny Metal API Notice: Key Request Available For Approval")
  end

  #email for requester when their key will expire in 30 days
  def expiry_warning_msg(user, user_key)
    @recipient = user
    @user_key = user_key
    mail(:to => @recipient.email,
         :subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Will Expire Soon")
  end

  #email for requester when their key expires
  def expiry_msg(user, user_key)
    @recipient = user
    @user_key = user_key
    mail(:to => @recipient.email,
         :subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Has Expired")
  end

  #email for requester when their application has been reopened
  def app_reset_msg(user, user_key)
    @recipient = user
    @user_key = user_key
    mail(:to => @recipient.email, 
  	 :subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Application Has Been Reopened")
  end

  #email for requester when process is complete and they have a key
  def key_approved_msg(user, user_key)
    @recipient = user
    @user_key = user_key
    mail(:to => @recipient.email, 
         :subject => "Shiny Metal API Notice: Your #{@user_key.name} Key Application Has Been Approved!")
  end

  #email for admin when all approvers have approved
  def everyone_approved_key(admin, user_key)
    @recipient = admin
    @user_key = user_key
    mail(:to => @recipient.email, 
         :subject => "Shiny Metal API Notice: #{@user_key.name} Key Has Been Approved by All Parties")
  end
end
