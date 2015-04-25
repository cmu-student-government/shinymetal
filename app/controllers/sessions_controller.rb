# Manages logging in and logging out.
class SessionsController < ApplicationController
 
  # GET /login
  def login
    # Get the user's andrew Id through Shibboleth.
    remote_user = Rails.env.development? ? "aditisar" : request.env["REMOTE_USER"]
    
    if remote_user.blank?
      render_500
    else
      # Shibboleth stores email address format, so split off the email part.
      andrew_id = remote_user.split("@")[0].downcase
      user = User.find_by_andrew_id(andrew_id)

      # Create a new user account for any CMU person not already in the system.
      user ||= new_user(andrew_id)
      
      # Do not allow inactive users to login.
      if user.active
        session[:user_id] = user.id
        flash[:notice] = "Welcome, #{user.name}! You are now logged in."
        redirect_to home_path
      else
        flash[:alert] = "You are not permitted to login because your account has been suspended."
        redirect_to root_path
      end
    end
  end

  
  # GET /logout
  def logout
    # Log out of the application.
    session[:user_id] = nil
    # Log out of Shibboleth.
    redirect_to "https://webiso.andrew.cmu.edu/logout.cgi"
  end
  
  private
  # Creates a User in the database.
  # @param andrew_id [String] The andrew id of the new User object.
  def new_user(andrew_id)
    user = User.new
    user.andrew_id = andrew_id
    # If the app has just been created, the first user is an administrator.
    # Otherwise, everyone starts as a requester.
    user.role = User.first.nil? ? "admin" : "requester"
    user.save!
  end
end
