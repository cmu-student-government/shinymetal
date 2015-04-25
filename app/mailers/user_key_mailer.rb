# Manages emails that are sent automatically via cronjob (for expiring keys)
# or immediately after doing some action on the site.
class UserKeyMailer < ApplicationMailer

  # This will not send any real email in development mode.
  # Instead, email will be opened in browser.

  # Email for user when they submit an application.
  # @param user [User] Requester who submitted the key.
  def submitted_msg(user)
    @recipient = user
    mail(:to => @recipient.email,
         :subject => "The Bridge API Notice: Key Request Submitted")
  end

  # Emails for admins when an application has been submitted.
  # @param user [User] Requester who submitted the key.
  # @param user_key [UserKey] The user key that the requester submitted.
  def admin_submit_msg(user, user_key)
    @user = user
    @user_key = user_key
    mail(:to => User.admin.map(&:email),
         :subject => "The Bridge API Notice: Key Request Submitted")
  end

  # Emails for approvers when a key has been marked ready for approval.
  # @param user [User] Requester who submitted the key.
  # @param user_key [Userkey] The user key that the requester submitted.
  def share_with_approver_msg(user, user_key)
    @user = user
    @user_key = user_key
    mail(:to => User.approvers_only.map(&:email),
         :subject => "The Bridge API Notice: Key Request Available For Approval")
  end

  # Email for requester when their key will expire in 30 days.
  # @param user [User] Requester who owns the key.
  # @param user_key [UserKey] The user key about to expire.
  # @note This is executed as part of a cronjob.
  def expiry_warning_msg(user, user_key)
    @recipient = user
    @user_key = user_key
    mail(:to => @recipient.email,
         :subject => "The Bridge API Notice: Your #{@user_key.name} Key Will Expire Soon")
  end

  # Email for requester when their key expired.
  # @param user [User] Requester who owns the key.
  # @param user_key [UserKey] The user key about to expire.
  # @note This is executed as part of a cronjob.
  def expiry_msg(user, user_key)
    @recipient = user
    @user_key = user_key
    mail(:to => @recipient.email,
         :subject => "The Bridge API Notice: Your #{@user_key.name} Key Has Expired")
  end

  # Email for requester when their application has been reopened.
  # @param user [User] Requester who owns the key.
  # @param user_key [UserKey] The user key that has been reset.
  def app_reset_msg(user, user_key)
    @recipient = user
    @user_key = user_key
    mail(:to => @recipient.email, 
  	 :subject => "The Bridge API Notice: Your #{@user_key.name} Key Application Has Been Reopened")
  end

  # Email for requester when process is complete and they have a key.
  # @param user [User] Requester who owns the key.
  # @param user_key [UserKey] The user key that has been approved.
  def key_approved_msg(user, user_key)
    @recipient = user
    @user_key = user_key
    mail(:to => @recipient.email, 
         :subject => "The Bridge API Notice: Your #{@user_key.name} Key Application Has Been Approved!")

  end

  # Email for admins when all approvers have approved.
  # @param user_key [UserKey] The user key that has been approved.
  def everyone_approved_key(user_key)
    @user_key = user_key
    mail(:to => User.admin.map(&:email),
         :subject => "The Bridge API Notice: #{@user_key.name} Key Has Been Approved by All Parties")
  end
end
