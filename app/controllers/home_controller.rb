class HomeController < ApplicationController
  def index
    if logged_in?
      #for admin dashboard
      @pending_filter_keys = UserKey.awaiting_filters
      @pending_approval = UserKey.awaiting_confirmation
      
      #for requester dashboard
      current_user_keys = @current_user.user_keys
      @confirmed_keys = current_user_keys.confirmed
      @in_progress = current_user_keys.awaiting_submission
      @awaiting_admin_review = current_user_keys.awaiting_filters + current_user_keys.awaiting_confirmation
      @expired_keys = current_user_keys.expired
    end
  end

end
