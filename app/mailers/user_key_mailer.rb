class UserKeyMailer < ApplicationMailer
  def submitted_msg(current_user)
    @current_user = current_user
    # This will not send any real email in development mode.
    # Instead, the email will be opened in browser.
    email = "#{@current_user.andrew_id}@andrew.cmu.edu"
    mail(:to => email,
         :subject => "Shiny Metal API Notice: Key Submitted")
  end
end
