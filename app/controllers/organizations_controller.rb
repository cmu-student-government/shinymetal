class OrganizationsController < ApplicationController
  before_action :check_login

  # CanCan checks
  authorize_resource

  # GET /organizations
  def index
    @filters = Filter.alphabetical.page(params[:page])
  end

  # GET /organizations/1
  def show
    @organization = Organization.find(params[:id])
    @user_keys = @organization.user_keys
  end
end
