class QuestionsController < ApplicationController
  before_action :check_login
  before_action :set_user, only: [:show, :edit, :update]
  
  # CanCan checks
  authorize_resource

  # GET /users
  # search(filtering_params) used for search bar
  def index
    search_param = params[:search]
    # First, did we find a single matching user?
    matching_users = User.search(search_param).alphabetical
    if matching_users.size==1
      @user = matching_users.to_a.first
      redirect_to @user
    else # No single matching user, so list them instead
      @requesters = matching_users.requesters_only.page(params[:page])
      @staff = matching_users.staff_only.page(params[:page])
    end
  end

  # GET /users/1
  def show
    if @user.id == @current_user.id
      # This user is looking at their own data, so they see all their keys
      @user_keys = @user.user_keys.chronological
    else # This is a staffmember, so they only see submitted keys
      @user_keys = @user.user_keys.submitted.chronological
    end
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # PATCH /repopulate_columns
  def repopulate_columns
    if Column.repopulate
      redirect_to root_path, notice: "The columns in the system were successfully updated."
    else
      redirect_to root_path, alert: "The request to CollegiateLink failed. Please try again later."
    end
  end
    
  # PATCH /repopulate_organizations
  def repopulate_organizations
    if Organization.repopulate
      redirect_to organizations_url, notice: "The organizations look-up table was successfully updated."
    else
      redirect_to organizations_url, alert: "The request to CollegiateLink failed. Please try again later."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:role, :active)
    end
end
