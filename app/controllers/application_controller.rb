class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Copied from PATS like a boss
  private
  # Handling authentication
  def current_user
    current_session_user_id = session[:user_id]
    if current_session_user_id
      
      # For trying to log back in, when the user object no longer exists.
      # This prevents errors from happening when forgetting to logout, then running rake db:populate.
      # However, this is too slow for production.
      if Rails.env.development? and !(User.all.to_a.map{|o| o.id}.include?(current_session_user_id))
        session[:user_id] = nil
      else #Production and Test fetching user, which is faster but will error if user_id doesn't exist
        @current_user = User.find(current_session_user_id)
      end
      
    end
  end
  helper_method :current_user
  
  def logged_in?
    current_user
  end
  helper_method :logged_in?
  
  def check_login
    redirect_to login_url, alert: "Login to view this page." if current_user.nil?
  end
end
