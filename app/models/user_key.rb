class UserKey < ActiveRecord::Base
  # Relationships
  belongs_to :user
  has_many :user_key_organizations
  has_many :user_key_filters
  has_many :filters, through: :user_key_filters
  has_many :organizations, through: :user_key_organizations
  has_many :comments
  has_many :approvals
  has_many :approval_users, class_name: User, through: :approvals
  has_many :comment_users, class_name: User, through: :comments
  
  accepts_nested_attributes_for :comments, limit: 1
  
  # Validations
  # Statuses for keys are currently:
  #     awaiting_submission, if started by requester but not submitted to admin
  #     awaiting_filters, if it hasn't had filters assigned
  #     awaiting_confirmation, if not approved by everybody
  # or  confirmed
  STATUS_LIST = ["awaiting_submission", "awaiting_filters", "awaiting_confirmation", "confirmed"]
  
  validates_inclusion_of :status, in: STATUS_LIST
  
  validate :user_id_valid
  
  # Scopes
  scope :by_user, -> { joins(:user).order("andrew_id") }
  scope :by_time_submitted, -> { where("time_submitted IS NOT NULL").order(time_submitted: :desc) }
  
  #scopes dealing with status for dashboards
  scope :awaiting_filters, -> { where("status == ?", 'awaiting_filters')}
  scope :awaiting_confirmation, -> { where("status == ?", 'awaiting_confirmation')}
  scope :confirmed, -> { where("status == ?", 'confirmed')}
  scope :awaiting_submission, -> { where("status == ?", 'awaiting_submission')}
  scope :submitted, -> { where("status <> 'awaiting_submission'") }
  scope :expired, -> { where("time_expired < ?", DateTime.now)}
  
  # Methods
  
  # Simply counting all approvers and comparing approvals already earned
  # would have a bug when someone approves it but is soon demoted from approver.
  # So, only find the number of approvers who are currently still active "approvers"
  def approved_by_all?
    return self.approval_users.approvers_only.size == User.approvers_only.all.size
  end
  
  def approved_by?(user)
    return self.approval_users.approvers_only.to_a.include?(user)
  end
  
  def set_approved_by(user)
    return Approval.create(user_key_id: self.id, user_id: user.id)
  end
  
  def undo_set_approved_by(user)
    old_approval = self.approvals.by(user).first
    old_approval.destroy
  end
  
  # A key with 'allow_past' which is past the submission stage
  # will be considered to be "at" the submission stage
  # This is used in user_key show page
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

  # Used for index and show pages
  # def name
  #   "Application Key #{self.id}" 
  # end
  
  def set_status_as(sym)
    case sym
    when :awaiting_filters
      return set_key_as_submitted
    when :awaiting_confirmation
      return set_key_as_filtered
    when :confirmed
      return set_key_as_confirmed
    # Key can be reset to the very beginning of its lifecycle here
    when :awaiting_submission
      return set_key_as_awaiting_submission
    end
  end

  def gen_api_key
    if at_stage?(:confirmed)
      # the datetime of when the user_key was first requested
      date_string = self.time_submitted.to_s.split("")
      # the andrew_id of the user who requested the user_key
      andrew_id = self.user.andrew_id.split("")
      # add some spice (salt) to the key as well 
      salt = SETTINGS[:api_key_salt].split("")
      # intertwine the string of the andrewid and the date together to build
      # the hash. This is so we can compare the passed in token to a hash
      # we can recompute to ensure security and not have the key stored in 
      # the database. (ex: intertwining "hello" and "woo" => "hweololo")
      # eventually add in the salt
      hash_string = salt.zip(date_string, andrew_id).map{|a, b, c| c.nil? && b.nil? ? a : c.nil? ? a + b : a + b + c}.reduce(:+)
      # hash_string = date_string.zip(andrew_id).map{|a, b| b.nil? ? a : a + b}.reduce(:+)
      return Digest::SHA2.hexdigest hash_string
    else
      return "A key will be generated upon approval."
    end
  end

  private
  # Save changes to Ruby object to the database
  def save_changes
    self.save!
  end
  
  # Requirement for resetting a key
  def has_public_comments?
    return !self.comments.public_only.empty?
  end
  
  # When submitted, a key should be marked as ready for filters from admin
  # When filtered, a key should be marked as ready for confirmation
  def set_status_to(param_status)
    self.status = param_status
  end
  
  # When submitted, a key should have its requested date marked
  def set_time_to_now(param_time_attribute)
    self[param_time_attribute] = DateTime.now.in_time_zone("Pacific Time (US & Canada)")
  end
  
  # For a key being reset
  def reset_times
    self.time_submitted = nil
    self.time_filtered = nil
  end
  
  # For a key being reset
  def reset_approvals
    # Delete all existing approvals
    self.approvals.destroy_all
  end

  # When a key is submitted by requester to admin
  def set_key_as_submitted
    if at_stage? :awaiting_submission
      set_status_to("awaiting_filters")
      set_time_to_now(:time_submitted)
      save_changes
      return true
    end
    errors.add(:user_key, "cannot be submitted at this stage")
    return false
  end
  
  # When an admin submits the filter form so it can be approved by everyone
  def set_key_as_filtered
    if at_stage? :awaiting_filters
      set_status_to("awaiting_confirmation")
      set_time_to_now(:time_filtered)
      save_changes
      return true
    end
    errors.add(:user_key, "cannot be shared with approvers at this stage")
    return false
  end
  
  # When a key has been approved by everyone and is confirmed by admin
  def set_key_as_confirmed
    if at_stage? :awaiting_confirmation and self.approved_by_all?
      set_status_to("confirmed")
      set_time_to_now(:time_confirmed)
      save_changes
      return true
    end
    errors.add(:user_key, "cannot be confirmed at this stage")
    return false
  end
  
  # When a key has rejected and sent back to the requester
  # Can only be sent back after submission but before "confirmed" stage
  # Note: a key can only be reset if it has comments made by admin for the requester's benefit.
  def set_key_as_awaiting_submission
    if (at_stage? :awaiting_filters or at_stage? :awaiting_confirmation) and has_public_comments?
      set_status_to("awaiting_submission")
      reset_times
      reset_approvals
      # Keep any filters/comments that were applied, so dont reset those
      save_changes
      return true
    end
    errors.add(:user_key, "cannot be reset at this stage")
    return false
  end

  # Simple foreign key validation
  def user_id_valid
    unless User.all.to_a.map{|o| o.id}.include?(self.user_id)
      errors.add(:user_id, "is invalid")
      return false
    end
    return true
  end
end
