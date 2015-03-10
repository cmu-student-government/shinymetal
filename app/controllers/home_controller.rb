class HomeController < ApplicationController
  def index
  	unless current_user.nil?
  		@userkeys = UserKey.all
  		@pending_filter_keys = UserKey.where("status LIKE ?", 'awaiting_filters')
  		@pending_approval = UserKey.where("status LIKE ?", 'awaiting_confirmation')
  		@confirmed_keys = UserKey.where("status LIKE ?", 'confirmed')
  	end
  end

end
