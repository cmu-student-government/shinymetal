class HomeController < ApplicationController
  def index
    if logged_in?
      if @current_user.role? :is_staff
	@pending_filter_keys = UserKey.awaiting_filters.chronological
	@pending_approval = UserKey.awaiting_confirmation.chronological
	# According to CollegiateLink business logic, @bad_organizations should always be empty.
	# It is included here on the off chance that an organization is deleted from CollegiateLink.
	@bad_organizations = Organization.inactive_but_with_nonexpired_keys
      else # :requester
	current_user_keys = @current_user.user_keys.chronological
	@confirmed_keys = current_user_keys.confirmed
	@in_progress = current_user_keys.awaiting_submission
	@awaiting_admin_review = current_user_keys.awaiting_filters + current_user_keys.awaiting_confirmation
	@expired_keys = current_user_keys.expired
      end
    end
  end
end
