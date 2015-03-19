class UserKeysController < ApplicationController
  before_action :check_login
  before_action :set_user_key, only: [:show, :edit, :update, :destroy, :add_comment,
                                      :delete_comment, :approve_key, :undo_approve_key,
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
    # Set user_id of comment to current user's id in view
    if @user_key.update(user_key_params)
      redirect_to @user_key, notice: 'Comment was successfully added.'
    else
      # Have to reload comments also for the show page
      get_comments
      render :show
    end
  end
  
  # DELETE /user_keys/1/delete_comment/1
  def delete_comment
    # Delete single comment
    @bad_comment = Comment.find(params[:comment_id])
    @bad_comment.destroy
    redirect_to @user_key, notice: 'Comment was successfully deleted.'
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
  
  # PATCH/PUT /user_keys/1/approve_key/
  def approve_key
    if @user_key.set_approved_by(current_user)
      redirect_to @user_key, notice: 'You have successfully approved this key.'
    else
      redirect_to @user_key, alert: 'User key cannot be approved.'
    end
  end
  
  # PATCH/PUT /user_keys/1/undo_approve_key/
  def undo_approve_key
    if @user_key.undo_set_approved_by(current_user)
      redirect_to @user_key, notice: 'You have successfully revoked your approval for this key.'
    else
      redirect_to @user_key, alert: 'Approval for user key cannot be revoked approved.'
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
                                       :filter_ids => [],
                                       :comments_attributes => [:id, :message, :user_id])
    end
end
