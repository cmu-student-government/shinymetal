class SessionsController < ApplicationController
  def login
    remote_user = Rails.env.development? ? "mdf" : request.env["REMOTE_USER"]

    if remote_user.blank?
      render_500
    else
      andrew_id = remote_user.split("@")[0].downcase
      user = User.find_by_andrew_id(andrew_id)

      if !user
        user = User.new
        user.andrew_id = andrew_id
        user.role = ["jkcorrea", "mdf", "aditisar", "bklam"].include?(andrew_id) ? "admin" : "requester"
        user.save!
      end

      session[:idea_seed] = Time.now.to_i
      session[:andrew_id] = andrew_id
      flash[:notice] = "Welcome, #{user.name}! You are now logged in."
      redirect_to session[:return_to] || root_path
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to "https://webiso.andrew.cmu.edu/logout.cgi"
  end
end
