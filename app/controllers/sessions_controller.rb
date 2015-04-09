class SessionsController < ApplicationController
  def new
  end

  def create
    # TEMPORARILY allow anyone to login as anybody without authentication
    #user = User.authenticate(params[:login], params[:password])
    user = User.find_by_andrew_id(params[:login])
    if user
      session[:user_id] = user.id
      redirect_to home_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid login."
      render action: 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "You have been logged out."
  end
end