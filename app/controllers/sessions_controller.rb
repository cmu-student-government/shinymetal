class SessionsController < ApplicationController
  def login
    remote_user = Rails.env.development? ? "mdf" : request.env["REMOTE_USER"]

    if remote_user.blank?
      render_500
    else
      andrew_id = remote_user.split("@")[0].downcase
      user = User.find_by_andrew_id(andrew_id)

      # Create a new user account for any CMU person not already in the system
      user ||= new_user(andrew_id)
      
      # Do not allow inactive users to login 
      if user.active
        session[:user_id] = user.id
        flash[:notice] = "Welcome, #{user.name}! You are now logged in."
        redirect_to session[:return_to] || root_path
      else
        flash[:alert] = "You are not permitted to login because your account has been suspended."
        redirect_to root_path
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to "https://webiso.andrew.cmu.edu/logout.cgi"
  end
  
  private
  def new_user(andrew_id)
    user = User.new
    user.andrew_id = andrew_id
    user.role = ["jkcorrea", "mdf", "aditisar", "bklam"].include?(andrew_id) ? "admin" : "requester"
    user.save!
  end
end
