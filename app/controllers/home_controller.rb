class HomeController < ApplicationController
  def index
  	unless current_user.nil?
  		@pending_filter_keys = UserKey.awaiting_filters
  		@pending_approval = UserKey.awaiting_confirmation
  		@confirmed_keys = UserKey.confirmed
  		#currently pulls from list of all keys
  		#to be modified with addition of sessions
  		@in_progress = UserKey.awaiting_submission
  		@expired_keys = UserKey.expired

  	end
  end

end
