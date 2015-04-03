class OrganizationsController < ApplicationController
  before_action :check_login

  # CanCan checks
  authorize_resource

  # GET /organizations
  def index
    @organizations = Organization.alphabetical.page(params[:page])
  end

  # GET /organizations/1
  def show
    @organization = Organization.find(params[:id])
    @user_keys = @organization.user_keys
  end
  
  # PATCH /organizations/repopulate_organizations
  def repopulate_organizations
    if Organization.repopulate
      redirect_to organizations_url, notice: "The organizations look-up table was successfully updated."
    else
      redirect_to organizations_url, alert: "The request to CollegiateLink failed. Please try again later."
    end
  end
end
