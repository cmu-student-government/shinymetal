# Manages the personalized dashboard that logged-in users can see.
class HomeController < ApplicationController
  # CanCan checks; this is not the guest 'welcome' page.
  # Users must be logged in to see this dashboard.
  # However, there is no Home class, and we need tell CanCan this.
  authorize_resource class: false

  # GET /home
  # Note: this is NOT a response to the root url.
  # PagesController handles the root url.
  # Unlike other Page objects, this page has functionality and requires users
  # to be logged in, so it gets its own controller.
  def index
    if @current_user.role? :is_staff
      @pending_filter_keys = UserKey.awaiting_filters.chronological
      @pending_approval = UserKey.awaiting_confirmation.chronological
      # According to CollegiateLink business logic, @bad_organizations should always be empty.
      # It is included here on the off chance that an organization is deleted from CollegiateLink.
      @bad_organizations = Organization.inactive_but_with_nonexpired_keys
    else # :requester
      current_user_keys = @current_user.user_keys.chronological
      @confirmed_keys = current_user_keys.confirmed
      @in_progress = current_user_keys.awaiting_submission
      @awaiting_admin_review = current_user_keys.awaiting_filters + current_user_keys.awaiting_confirmation
      @expired_keys = current_user_keys.expired
    end
  end

  # GET /admin
  # Basic admin's panel
  def admin
    authorize! :administer, :home
    @active_questions = Question.active.chronological.to_a
  end

  # GET /admin_docs
  # Download admin docs
  def admin_docs
    authorize! :administer, :home
    pdf = File.join(Rails.root, "doc/BridgeAPIAdminHowto.pdf")
    send_file(pdf, filename: "BridgeAPIAdminHowto.pdf", disposition: 'inline', type: "application/pdf")
  end

  # PATCH /repopulate_columns
  def repopulate_columns
    if Column.repopulate
      redirect_to admin_path, notice: "The columns in the system were successfully updated."
    else
      redirect_to admin_path, alert: "The request to CollegiateLink failed. Please try again later."
    end
  end

  # PATCH /repopulate_organizations
  def repopulate_organizations
    if Organization.repopulate
      redirect_to admin_path, notice: "The organizations look-up table was successfully updated."
    else
      redirect_to admin_path, alert: "The request to CollegiateLink failed. Please try again later."
    end
  end
end
