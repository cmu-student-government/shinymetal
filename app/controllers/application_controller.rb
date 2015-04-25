# Manages recalling the user's id stored in the session hash.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  private
  # Authentication by fetching User using user_id in session hash.
  def current_user
    current_session_user_id = session[:user_id]
    @current_user ||= User.find_by_id(current_session_user_id) if current_session_user_id
  end
  helper_method :current_user
  
  # Checks that the user is logged in; used to instantiate @current_user.
  # @return [User, nil] The User that was refetched, or nil if not logged in.
  def logged_in?
    current_user
  end
  helper_method :logged_in?
  
  # If a user is not logged in and they visit a secured URL,
  # they will get and error and return to the welcome page. 
  def check_login
    redirect_to root_url, alert: "You must login to view this page." if current_user.nil?
  end
end
