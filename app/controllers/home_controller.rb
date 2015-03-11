class HomeController < ApplicationController
  def index
  	unless current_user.nil?
  		#for admin dashboard
  		@pending_filter_keys = UserKey.awaiting_filters
  		@pending_approval = UserKey.awaiting_confirmation
  		@confirmed_keys = UserKey.confirmed
  		
  		#for requester dashboard
  		#currently pulls from list of all keys
  		#to be modified with addition of sessions
  		@in_progress = UserKey.awaiting_submission
  		@awaiting_admin_review = @pending_approval + @pending_filter_keys
  		@expired_keys = UserKey.expired

  	end
  end

end
