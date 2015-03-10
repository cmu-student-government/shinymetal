class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  #Needs to be changed once authentication is added, for testing purposes
  def current_user
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user = "admin"
  end

end
