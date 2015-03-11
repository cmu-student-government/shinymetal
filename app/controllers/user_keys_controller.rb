class UserKeysController < ApplicationController
  before_action :set_user_key, only: [:show, :edit, :update, :destroy, :add_comment,
                                      :set_as_submitted, :set_as_filtered, :set_as_confirmed]

  # GET /user_keys
  def index
    @user_keys = UserKey.by_user.page(params[:page])
  end

  # GET /user_keys/1
  def show
    get_comments
  end

  # GET /user_keys/new
  def new
    @user_key = UserKey.new
  end

  # GET /user_keys/1/edit
  def edit
  end

  # POST /user_keys
  def create
    @user_key = UserKey.new(user_key_params)
    if @user_key.save
      redirect_to @user_key, notice: 'User key was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /user_keys/1
  def update
    if @user_key.update(user_key_params)
      redirect_to @user_key, notice: 'User key was successfully updated.'
    else
      render :edit
    end
  end
  
  # PATCH/PUT /user_keys/1/add_comment
  def add_comment
    @user_key.update(user_key_params)
    redirect_to @user_key
  end

  # DELETE /user_keys/1
  def destroy
    @user_key.destroy
    redirect_to user_keys_url, notice: 'User key was successfully destroyed.'
  end
  
  # PATCH/PUT /user_keys/1/set_as_submitted
  def set_as_submitted
    if @user_key.set_key_as("submitted")
      redirect_to @user_key, notice: 'User key request was successfully submitted.'
    else
      redirect_to @user_key, alert: 'User key request cannot be submitted.'
    end
  end
  
  # PATCH/PUT /user_keys/1/set_as_filtered
  def set_as_filtered
    if @user_key.set_key_as("filtered")
      redirect_to @user_key, notice: 'User key has had its filters assigned and is now visible to approvers.'
    else
      redirect_to @user_key, alert: 'User key filters cannot be submitted for approvers.'
    end
  end
  
  # PATCH/PUT /user_keys/1/set_as_approved
  def set_as_confirmed
    if @user_key.set_key_as("confirmed")
      redirect_to @user_key, notice: 'User key was successfully confirmed. All steps are complete.'
    else
      redirect_to @user_key, alert: 'User key cannot be confirmed.'
    end
  end

  private
    # Build a blank comment form 
    def get_comments
      @comments = @user_key.comments.chronological
      @comment = @user_key.comments.build
    end
      
    def set_user_key
      @user_key = UserKey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_key_params
      params.require(:user_key).permit(:user_id, :time_expired, :application_text,
                                       :filter_ids => [], :approval_ids => [],
                                       :comments_attributes => [:id, :message, :user_id])
    end
end
