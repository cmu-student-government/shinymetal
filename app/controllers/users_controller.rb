class UsersController < ApplicationController
  before_action :check_login
  before_action :set_user, only: [:show, :edit, :update]

  # CanCan checks
  authorize_resource

  # GET /users
  # search(filtering_params) used for search bar
  def index
    @requesters = User.requesters_only.page(params[:page])
    @staff = User.staff_only.page(params[:page])
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

  def search
    search_param = params[:term]
    matching_users = User.search(search_param).collect { |u| { value: "#{u.name} (#{u.andrew_id})", data: u.id } }
    render json: { suggestions: matching_users }
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
