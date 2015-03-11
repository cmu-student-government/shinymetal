class HomeController < ApplicationController
  def index
  	unless current_user.nil?
  		#these should be moved to scopes in userkey eventually
  		@pending_filter_keys = UserKey.where("status LIKE ?", 'awaiting_filters')
  		@pending_approval = UserKey.where("status LIKE ?", 'awaiting_confirmation')
  		@confirmed_keys = UserKey.where("status LIKE ?", 'confirmed')
  		#placeholders to be modified with addition of sessions
  		#should add expired scope in user_key model
  		@existing_keys = UserKey.where("value IS NOT NULL")
  		@expired_keys = UserKey.where("value IS NOT NULL")
  	end
  end

end
