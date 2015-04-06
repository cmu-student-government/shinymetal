class OrganizationsController < ApplicationController
  before_action :check_login

  # CanCan checks
  authorize_resource

  # GET /organizations
  def index
    @organizations = Organization.alphabetical.page(params[:page])
    # For the warning message (that is also shown on the home page)
    @bad_organizations = Organization.inactive_but_with_nonexpired_keys
  end

  # GET /organizations/1
  def show
    @organization = Organization.find(params[:id])
    @user_keys = @organization.user_keys
  end
end
