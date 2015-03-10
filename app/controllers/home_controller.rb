class HomeController < ApplicationController
  def index
  	unless current_user.nil?
  		@userkeys = UserKey.all
  	end
  end

end
