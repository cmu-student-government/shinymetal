class UserKeysController < ApplicationController
  before_action :check_login
  before_action :set_user_key, only: [:show, :edit, :update, :destroy, :add_comment,
                                      :delete_comment, :approve_key, :undo_approve_key,
                                      :set_as_submitted, :set_as_filtered,
                                      :set_as_confirmed, :set_as_reset]

  # GET /user_keys
  def index
    # Staffmember only wants to see key applications that have been submitted.
    @user_keys = UserKey.submitted.by_user.page(params[:page])
  end
  
  # GET /own_user_keys
  def own_user_keys
    # Any logged-in user can see all of their own keys.
    @user_keys = @current_user.user_keys.page(params[:page])
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
    # Set user_key's user to be the current user
    params[:user_key][:user_id] = @current_user.id
    @user_key = UserKey.new(create_user_key_params)
    if @user_key.save
      redirect_to @user_key, notice: 'User key was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /user_keys/1
  def update
    if @current_user.role? :admin
      # Admin is allowed to add filters, orgs, active, etc.
      whitelist = admin_update_user_key_params
    else
      # The key's owner can change the application text if it hasn't been submitted yet
      whitelist = update_user_key_params
    end
    if @user_key.update(whitelist)
      redirect_to @user_key, notice: 'User key was successfully updated.'
    else
      render :edit
    end
  end
  
  # PATCH/PUT /user_keys/1/add_comment
  def add_comment
    # Set user_id of new comment to current user's id
    params[:user_key][:comments_attributes]["0"][:user_id] ||= @current_user.id
    if @user_key.update(comment_user_key_params)
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
    if @user_key.set_status_as :awaiting_filters
      redirect_to @user_key, notice: 'User key request was successfully submitted.'
    else
      redirect_to @user_key, alert: 'User key request cannot be submitted.'
    end
  end
  
  # PATCH/PUT /user_keys/1/set_as_filtered
  def set_as_filtered
    if @user_key.set_status_as :awaiting_confirmation
      redirect_to @user_key, notice: 'User key has had its filters assigned and is now visible to approvers.'
    else
      redirect_to @user_key, alert: 'User key filters cannot be submitted for approvers.'
    end
  end
  
  # PATCH/PUT /user_keys/1/set_as_approved
  def set_as_confirmed
    if @user_key.set_status_as :confirmed
      redirect_to @user_key, notice: 'User key was successfully confirmed. All steps are complete.'
    else
      redirect_to @user_key, alert: 'User key cannot be confirmed.'
    end
  end
  
  # PATCH/PUT /user_keys/1/set_as_reset
  def set_as_reset
    if @user_key.set_status_as :awaiting_submission
      redirect_to user_keys_url, notice: 'User key application was successfully returned to the requester with comments,
                                          and is no longer visible to staff.'
    else
      redirect_to @user_key, alert: 'User key cannot be reset.'
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
    def get_comments
      @public_comments = @user_key.comments.public_only.chronological
      @private_comments = @user_key.comments.private_only.chronological
      # Build a blank comment form 
      @comment = @user_key.comments.build
    end
      
    def set_user_key
      @user_key = UserKey.find(params[:id])
    end

    def create_user_key_params # Seperate, due to new and permanent user_id
      params.require(:user_key).permit(:user_id, :agree, :proposal_text_one, :proposal_text_two,
                                       :proposal_text_three, :proposal_text_four,
                                       :proposal_text_five, :proposal_text_six,
                                       :proposal_text_seven, :proposal_text_eight)
    end
    
    def update_user_key_params # For requester, upon updating application text
      
      params.require(:user_key).permit(:agree, :proposal_text_one, :proposal_text_two,
                                       :proposal_text_three, :proposal_text_four,
                                       :proposal_text_five, :proposal_text_six,
                                       :proposal_text_seven, :proposal_text_eight)
    end
    
    def comment_user_key_params # For anyone who can comment
      params.require(:user_key).permit(:comments_attributes => [:id, :message, :public, :user_id])
    end
    
    def admin_update_user_key_params # For admin, upon updating filters or anything else
      params.require(:user_key).permit(:time_expired, :active, :reason,
                                       :filter_ids => [], :organization_ids => [])
    end
end
