# A key application, and its associated form data and key value, to be created by a requester.
class UserKey < ActiveRecord::Base
  # Always make sure the user's name becomes nil if it is the same as the placeholder name.
  before_save :check_name

  # Relationships

  belongs_to :user

  # A User Key is the only thing that can be deleted in the system (while still associated).
  # Filters can be deleted if they are unused; everything else can only be deleted through user key.
  has_many :user_key_organizations, dependent: :destroy
  has_many :whitelists, dependent: :destroy
  has_many :user_key_columns, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :approvals, dependent: :destroy
  # 'has_many :answers' requires inverse_of, so that both the key and its answers
  # can be created at the same time in the application.
  has_many :answers, inverse_of: :user_key, dependent: :destroy

  has_many :questions, through: :answers
  has_many :columns, through: :user_key_columns
  has_many :organizations, through: :user_key_organizations
  has_many :approval_users, class_name: User, through: :approvals
  has_many :comment_users, class_name: User, through: :comments

  # Only one comment can be added through a time.
  # Comments are not deleted through the nested form; they are deleted through their own form.
  accepts_nested_attributes_for :comments, limit: 1
  # A user key's answers are created when the user key is created. After that, answers cannot be
  #  added or deleted unless the user key is deleted.
  accepts_nested_attributes_for :answers
  # Nested whitelists will cause validations to fail if they are completely blank.
  accepts_nested_attributes_for :whitelists, allow_destroy: true

  # Validations
  # Statuses for keys are currently:
  #     awaiting_submission, if started by requester but not submitted to admin
  #     awaiting_filters, if it hasn't had filters assigned
  #     awaiting_confirmation, if not approved by everybody
  # or  confirmed
  STATUS_LIST = ["awaiting_submission", "awaiting_filters", "awaiting_confirmation", "confirmed"]

  validates_presence_of :user
  validates_inclusion_of :status, in: STATUS_LIST

  # Validate that the requirements of the submission step and the filtering step
  # are always met afterwards.
  # We do not validate that keys are always approvable afterwards ("confirmed" step),
  # because more approvers may be added to the system later.
  # We do not validate that keys are always at "awaiting_submission"
  # because a key is only set to this state when it is being reset, which requires comments,
  # but not all keys need comments.
  for status in STATUS_LIST
    if status == "awaiting_filters" or status == "awaiting_confirmation"
      validate Proc.new { |key| key.can_be_set_to?(status.to_sym) },
               if: Proc.new { |key| key.at_stage?(status.to_sym, true) }
    end
  end

  # Scopes

  # These scopes are used to organize keys in index pages.
  scope :by_user, -> { joins(:user).order("andrew_id") }
  scope :chronological, -> { order(time_submitted: :desc).order(time_filtered: :desc).order(time_confirmed: :desc).order(time_expired: :desc) }

  # These scopes are used for organizing keys on user dashboards.
  scope :awaiting_filters, -> { where("status = ?", 'awaiting_filters')}
  scope :awaiting_confirmation, -> { where("status = ?", 'awaiting_confirmation')}
  scope :awaiting_submission, -> { where("status = ?", 'awaiting_submission')}
  scope :expired, -> { where("time_expired < ?", DateTime.now)}
  # This is also the first of three scopes used to restrict permitted keys in the API controller.
  scope :confirmed, -> { where("status = ?", 'confirmed')}

  # This scope is used to restrict the keys that the staff and admins can view.
  # They cannot see applications that have not been submitted yet.
  scope :submitted, -> { where("status <> 'awaiting_submission'") }

  # This is the second of three scopes used ot restrict permitted keys in the API controller.
  scope :not_expired, -> { where("time_expired >= ?", DateTime.now) }


  # This is the third of three scopes used to restrict permitted keys in the API controller.
  scope :active, -> { where(active: true) }

  # Used in a cron job to send automatic emails the month before a key expires.
  scope :expires_in_a_month, -> { where("time_expired = ?", 30.days.from_now.to_date) }

  # Used in a cron job to send automatic emails when the key expires that day.
  scope :expires_today, -> { where("time_expired = ?", Date.today) }

  # Methods

  # Determine if the approver viewing the user key's permissions has approved it yet or not.
  #
  # @param user [User] The staff_approver or admin who is viewing the user key's permissions.
  # @return [Boolean] True iff the given user has an Approval for this key.
  def approved_by?(user)
    return self.approval_users.to_a.include?(user)
  end

  # Create an Approval by an approver user for this user key application.
  #
  # @param user [User] The staff_approver or admin who is approving this key.
  # @return [Boolean] True iff the given user does not have an Approval for this key yet.
  # @note Adds an error if it returns false.
  def set_approved_by(user)
    unless approved_by?(user)
      Approval.create(user_key_id: self.id, user_id: user.id)
      return true
    end
    errors.add(:base, "You have already approved this key.")
    return false
  end

  # Destroy the Approval created by the approver user for this user key application.
  #
  # @param user [User] The staff_approver or admin who is revoking approval for this key.
  # @return [Boolean] True iff the given user had an Approval for this key coming in.
  # @note Adds an error if it returns false.
  def undo_set_approved_by(user)
    if approved_by?(user)
      # A user should only ever have at most one Approval for a given key,
      #   so 'take' grabs that one Approval.
      old_approval = self.approvals.by(user).take
      old_approval.destroy
      return true
    end
    errors.add(:base, "You have not approved this key yet.")
    return false
  end

  # Used in the user key show page to indicate whether or not the key has expired.
  #
  # @return [Boolean] True only if the key has a value for time_expired, and that value is before today's date.
  def expired?
    return false if self.time_expired.nil?
    return self.time_expired < Date.today
  end

  # Used in the user key show page and the home page to indicate which of their keys will expire soon.
  #
  # @return [Boolean] True only if the key has a value for time_expired, and that value is in the next 30 days.
  def will_expire_soon?
    return false if self.time_expired.nil? or self.expired?
    return self.time_expired < 30.days.from_now
  end

  # Class method to search for keys whose names match a search term.
  #
  # @param term [String] The term being searched for.
  # @param max [Integer] The maximum number of keys allowed in the returned collection.
  # @return [ActiveRecord::Relation] Collection of user keys, capped by the max, which match the search term.
  def self.search(term, max=5)
    term = "%#{term.to_s.downcase}%"
    name = 'LOWER(name)'
    where("#{name} LIKE ?", term).limit(max)
  end

  # Determines if the form is ready to be reset, or submitted, or shared with approvers, or confirmed.
  #
  # @param sym [Symbol] The status that they key is about to be set to.
  # @return [Boolean] True iff the key's status can be set to sym.
  def can_be_set_to? sym
    case sym # Do false cases first.
    when :awaiting_submission
      # Only keys being "reset" are "set" to awaiting_submission.
      # Every key starts at awaiting_submission by default and don't have these checks.
      # To be reset, a key must be active and have public comments for the key owner to see.
      return false unless (at_stage? :awaiting_filters or at_stage? :awaiting_confirmation)
      return false unless (has_public_comments? and self.active)
    when :awaiting_filters
      # Check that the requester has filled in their form.
      return false unless at_stage? :awaiting_submission
      return false unless request_form_done?
    when :awaiting_confirmation
      # Check by admin that the key is ready to be approved by all approvers in the system.
      return false unless at_stage? :awaiting_filters
      return false if self.time_expired.nil?
    when :confirmed
      # Check by admin that the key has been approved by everyone and can be confirmed.
      return false unless at_stage? :awaiting_confirmation
      # Simply counting all approvers and comparing approvals already earned
      # would have a bug when someone approves it but is soon demoted from approver.
      # So, only find the number of approvers who are currently still active "approvers".
      return false if !(self.approval_users.approvers_only.size == User.approvers_only.size)
    end
    return true
  end

  # Check in user key view pages and validations what stage the user key is in.
  #
  # @param sym [Symbol] Possible user key status.
  # @param allow_past [Boolean] If true, then, for example, if the key is past the submission stage,
  #   consider the key to be "at" the submission stage.
  # @return [Boolean] True iff the user key is at sym's stage, or is past the stage (if allow_past).
  def at_stage?(sym, allow_past=false)
    case sym
    when :awaiting_submission
      if allow_past
        return true
      else
        return self.status == "awaiting_submission"
      end
    when :awaiting_filters
      if allow_past
        # The only stage we cannot be at is awaiting_submission
        return self.status != "awaiting_submission"
      else
        return self.status == "awaiting_filters"
      end
    when :awaiting_confirmation
      if allow_past
        # We must be at awaiting_confirmation stage or earlier
        return (self.status != "awaiting_submission" and self.status != "awaiting_filters")
      else
        return self.status == "awaiting_confirmation"
      end
    else # confirmed
      # We never pass confirmed stage, so only one case
      return self.status == "confirmed"
    end
  end

  # In index and show pages, overwrites the displayed key name if the name is blank.
  #
  # @return [String] Name of the key, or "Unnnamed Application" if the name is nil.
  def display_name
    if name.blank? # No name given yet, make up a temporary one
      return "Unnamed Application"
    else
      return name
    end
  end

  # Change the status of the key via the UserKeyController.
  #
  # @param sym [Symbol] A possible user key status.
  # @return [Boolean] True iff the status was successfully changed to the requested sym.
  def set_status_as(sym)
    today = DateTime.now.in_time_zone("Pacific Time (US & Canada)")
    case sym
    when :awaiting_filters
      return set_key_as_(sym, :time_submitted, today, "The key cannot be submitted. Please check that you
               have completed all requires fields.")
    when :awaiting_confirmation
      return set_key_as_(sym, :time_filtered, today, "The key needs an expiration date.")
    when :confirmed
      return set_key_as_(sym, :time_confirmed, today, "The key cannot be released until it has been approved by all approvers.")
    # Key can be reset to the very beginning of its lifecycle here.
    when :awaiting_submission
      # When resetting the key, time_filtered is set to nil, but time_submitted is not because
      #   keeping the time_submitted allows requesters to see that a submission was already attempted.
      return set_key_as_(sym, :time_filtered, nil, "The key cannot be reset unless the key is both active, has not been confirmed yet,
                         and has an Administrator note explaining the issue to the requester.")
    end
  end

  # Calculate and print the API key, iff the key has been confirmed. Does not store the API key.
  #
  # @return [String] The value of the key, or placeholder text if the user key has no key yet.
  def gen_api_key
    if at_stage?(:confirmed)
      # Start with the datetime of when the user_key was first requested.
      date_string = self.time_submitted.to_s.split("")
      # Get the andrew_id of the user who requested the user_key.
      andrew_id = self.user.andrew_id.split("")
      # Get the salt for the key as well.
      salt = SETTINGS[:api_key_salt].split("")
      # Intertwine the string of the andrewid, date, and salt together to build
      #   the hash. This is so we can compare the passed in token to a hash
      #   we can recompute to ensure security and not have the key stored in
      #   the database. (ex: intertwining "hello" and "woo" => "hweololo")
      hash_string = salt.zip(date_string, andrew_id).map{|a, b, c| c.nil? && b.nil? ? a : c.nil? ? a + b : a + b + c}.reduce(:+)
      return Digest::SHA2.hexdigest hash_string
    else
      return "A key will be generated upon approval."
    end
  end

  private
  # Save changes to the Ruby object to the database.
  def save_changes
    self.save!
  end

  # Check if any administrator comments have been made. Used as a requirement for resetting a key.
  #
  # @return [Boolean] True iff administrator comments exist for this key.
  def has_public_comments?
    return !self.comments.public_only.empty?
  end

  # Check if the required fields are filled in. Used as a requirement for submitting a key.
  #
  # @return [Boolean] True iff required fields are filled in and the key has a name.
  def request_form_done?
    self.answers.each {|answer| return false if answer.message.blank? and answer.question.required }
    return !self.name.blank?
  end

  # Destroy each Approval for this key.
  def reset_approvals
    self.approvals.destroy_all
  end

  # Check that the key can have its status changed to next_stage.
  # Then, change the status of the key to next_stage, and change the timestamp to the new value.
  # If the key is being set to awaiting_submission, then it is being reset, and approvals
  # are deleted as well.
  # If there was an error, add an error to the error hash and do nothing else.
  #
  # @param next_stage [Symbol] The status the key is being updated to.
  # @param timestamp [Symbol] The time attribute being updated.
  # @param timestamp_value [DateTime, nil] The new value for the timestamp; today, or nil.
  # @param error [String] The error added if false is returned.
  # @return [Boolean] True iff the change was successful.
  # @note Adds an error if it returns false.
  def set_key_as_(next_stage, timestamp, timestamp_value, error)
    if self.can_be_set_to?(next_stage)
      self.status = next_stage.to_s
      if next_stage == :awaiting_submission # Reset the key
        reset_approvals # Keep any filters/comments that were applied, so dont reset those
      end # Advance the key's progress
      self[timestamp] = timestamp_value
      save_changes
      return true
    end
    errors.add(:base, error)
    return false
  end

  # Callbacks

  # Don't allow "Unnamed Application" to be the name. Technically it would not cause problems,
  # but this is the display name for applications without names, so it could cause confusion.
  def check_name
    self.name = nil if self.name == "Unnamed Application"
  end
end
