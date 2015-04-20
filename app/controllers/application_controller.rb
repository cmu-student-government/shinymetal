class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  # Handling authentication
  def current_user
    current_session_user_id = session[:user_id]
    @current_user = User.find_by_id(current_session_user_id) if current_session_user_id
  end
  helper_method :current_user
  
  def logged_in?
    current_user
  end
  helper_method :logged_in?
  
  def check_login
    redirect_to root_url, alert: "You must login to view this page." if current_user.nil?
  end
end
