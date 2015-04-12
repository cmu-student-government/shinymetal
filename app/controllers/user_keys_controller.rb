class UserKeysController < ApplicationController
  before_action :check_login
  before_action :set_user_key, except: [:index, :own_user_keys, :new, :create, :search]

  # CanCan checks
  authorize_resource

  # GET /user_keys
  def index
    # Staffmember only wants to see key applications that have been submitted.
    @user_keys = UserKey.submitted.chronological.by_user.page(params[:page])
  end

  # GET /own_user_keys
  def own_user_keys
    # Any logged-in user can see all of their own keys.
    @user_keys = @current_user.user_keys.chronological.page(params[:page])
  end

  # GET /user_keys/1
  def show
    get_comments
  end

  # GET /user_keys/new
  def new
    @user_key = UserKey.new
    get_questions
    build_answers
  end

  # GET /user_keys/1/edit
  def edit
  end

  # POST /user_keys
  def create
    # Questions needed to sanitize ids, or for question data in render :new if there is an error.
    get_questions
    # Destroy any question_id that was passed in (none should have been passed in),
    # then match correct questions to answers based on index.
    sanitize_question_ids
    # Build new key
    @user_key = UserKey.new(create_user_key_params)
    # Set user_key's user to be the current user
    @user_key.user_id = @current_user.id
    if @user_key.save
      redirect_to @user_key, notice: 'User key was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /user_keys/1
  def update
    if @current_user.role? :admin and !(@user_key.at_stage? :awaiting_submission)
      # Admin is allowed to add filters, orgs, active, etc. after the text fields are submitted
      whitelist = admin_update_user_key_params
    else
      # The key's owner (admin or requester) can change the application text if it isn't submitted yet
      whitelist = owner_user_key_params
    end
    if @user_key.update(whitelist)
      redirect_to @user_key, notice: 'User key was successfully updated.'
    else
      render :edit
    end
  end

  # PATCH/PUT /user_keys/1/add_comment
  def add_comment
    # Set user_id of new comment to current user's id.
    # This takes the single nested comment_attribute;
    # always set the commenter's id to the current user's id.
    params[:user_key][:comments_attributes]["0"][:user_id] = @current_user.id
    # FIXME Adding a user_key_comment note from administrator should send email to requester?
    if @user_key.update(comment_user_key_params)
      redirect_to @user_key, notice: 'Comment was successfully added.'
    else
      get_comments
      render :show
    end
  end

  # DELETE /user_keys/1/delete_comment/1
  def delete_comment
    # Delete single comment;
    # It should usually be the case that comment cannot be deleted
    # if role? requester and at_stage? :awaiting_submission stage,
    # Since admin can't see the comments at that point in time.
    # FIXME: should this be validated?
    @bad_comment = Comment.find(params[:comment_id])
    @bad_comment.destroy
    redirect_to @user_key, notice: 'Comment was successfully deleted.'
  end

  # DELETE /user_keys/1
  def destroy
    @user_key.destroy
    if @current_user.role? :is_staff
      redirect_to user_keys_url, notice: 'User key was successfully deleted.'
    else
      redirect_to own_user_keys_url, notice: 'Application was successfully deleted.'
    end
  end

  # PATCH/PUT /user_keys/1/set_as_submitted
  def set_as_submitted
    if @user_key.set_status_as :awaiting_filters
      # Email confirmation and page confirmation
      UserKeyMailer.submitted_msg(@current_user).deliver
      UserKeyMailer.admin_submit_msg(User.admin.first, @current_user, @user_key).deliver
      redirect_to @user_key, notice: 'User key request was successfully submitted.'
    else
      get_comments
      render :show
    end
  end

  # PATCH/PUT /user_keys/1/set_as_filtered
  def set_as_filtered
    if @user_key.set_status_as :awaiting_confirmation
      UserKeyMailer.share_with_approver_msg(@user_key.user, @user_key).deliver
      redirect_to @user_key, notice: 'User key has had its filters assigned and is now visible to approvers.'
    else
      get_comments
      render :show
    end
  end

  # PATCH/PUT /user_keys/1/set_as_approved
  def set_as_confirmed
    if @user_key.set_status_as :confirmed
      UserKeyMailer.key_approved_msg(@user_key.user, @user_key).deliver
      redirect_to @user_key, notice: 'User key was successfully confirmed. All steps are complete.'
    else
      get_comments
      render :show
    end
  end

  # PATCH/PUT /user_keys/1/set_as_reset
  def set_as_reset
    if @user_key.set_status_as :awaiting_submission
      UserKeyMailer.app_reset_msg(@user_key.user, @user_key).deliver
      redirect_to user_keys_url, notice: 'User key application was successfully returned to the requester with comments,
                                          and is no longer visible to staff.'
    else
      get_comments
      render :show
    end
  end

  # PATCH/PUT /user_keys/1/approve_key/
  def approve_key
    if @user_key.set_approved_by(@current_user)
      redirect_to @user_key, notice: 'You have successfully approved this key.'
    else
      get_comments
      render :show
    end
  end

  # PATCH/PUT /user_keys/1/undo_approve_key/
  def undo_approve_key
    if @user_key.undo_set_approved_by(@current_user)
      redirect_to @user_key, notice: 'You have successfully revoked your approval for this key.'
    else
      get_comments
      render :show
    end
  end

  def search
    search_param = params[:term]
    matching_keys = UserKey.submitted.search(search_param).collect { |u| { value: "#{u.name}", data: u.id } }
    render json: { suggestions: matching_keys }
  end

  private
    # get_comments doesn't work well as a callback, because
    # empty built @comment gets saved as part of set_as_submitted-type updates.
    # Also, the other comments need to be loaded before the blank form is built,
    # otherwise @comment becomes all existing comments plus the blank form.
    def get_comments
      @public_comments = @user_key.comments.public_only.chronological
      @private_comments = @user_key.comments.private_only.chronological
      @comment = @user_key.comments.build
    end
    
    def sanitize_question_ids
      # question_id is something only we should be able to change.
      # It is included in params so that we can set question_id as part of updating nested attributes.
      params[:user_key][:answers_attributes].each{|k,v| v[:question_id] = nil}
      @questions.each_with_index{|q,i| params[:user_key][:answers_attributes][i.to_s][:question_id] = q.id}
      # Any extra answers that the user hacked in will error out due to missing a question_id.
    end
    
    def get_questions
      @questions = Question.active.chronological.to_a
    end

    def build_answers
      @questions.size.times do
        @user_key.answers.build
      end
    end

    def set_user_key
      @user_key = UserKey.find(params[:id])
    end
    
    def create_user_key_params # For requester, upon creating application text
      params.require(:user_key).permit(:name, answers_attributes: [:id, :message, :question_id])
    end

    def owner_user_key_params # For requester, upon updating application text
      params.require(:user_key).permit(:name, answers_attributes: [:id, :message])
    end

    def comment_user_key_params # For anyone who can comment
      params.require(:user_key).permit(:comments_attributes => [:id, :message, :public, :user_id])
    end

    def admin_update_user_key_params # For admin, upon updating filters or anything else
      params.require(:user_key).permit(:time_expired, :active, :reason, :column_ids => [],
                                       :organization_ids => [], :whitelists_attributes => [:id, :resource, :_destroy, :filter_ids => []])
    end
end
