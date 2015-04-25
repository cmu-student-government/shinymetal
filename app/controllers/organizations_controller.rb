# Manages organization functionality,
# available for all admins and staff.
class OrganizationsController < ApplicationController
  before_action :check_login

  # CanCan checks
  authorize_resource

  # GET /organizations
  def index
    @organizations = Organization.active.alphabetical.page(params[:page])
    # For the warning message (that is also shown on the home page).
    # This should never be necessary, but is included just in case
    # CollegiateLink changes the ids of some organizations.
    # The concern is that keys should not accidentally have access
    # to the wrong organizations.
    @bad_organizations = Organization.inactive_but_with_nonexpired_keys
  end

  # GET /organizations/1
  def show
    @organization = Organization.find(params[:id])
    @user_keys = @organization.user_keys
  end
end
