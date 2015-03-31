class UserKey < ActiveRecord::Base
  before_save :check_name
  
  # Relationships
  belongs_to :user
  has_many :user_key_organizations
  has_many :whitelists, inverse_of: :user_key
  has_many :user_key_columns
  has_many :columns, through: :user_key_columns
  has_many :organizations, through: :user_key_organizations
  has_many :comments
  has_many :approvals
  has_many :approval_users, class_name: User, through: :approvals
  has_many :comment_users, class_name: User, through: :comments
  
  accepts_nested_attributes_for :comments, limit: 1
  accepts_nested_attributes_for :whitelists, allow_destroy: true
  
  # Validations
  # Statuses for keys are currently:
  #     awaiting_submission, if started by requester but not submitted to admin
  #     awaiting_filters, if it hasn't had filters assigned
  #     awaiting_confirmation, if not approved by everybody
  # or  confirmed
  STATUS_LIST = ["awaiting_submission", "awaiting_filters", "awaiting_confirmation", "confirmed"]
  # Quick list for the 8 proposal_text symbols
  TEXT_FIELD_LIST = ["one","two","three","four","five","six","seven","eight"].map{|num| "proposal_text_#{num}".to_sym }
  
  validates_inclusion_of :status, in: STATUS_LIST
  
  validate :user_id_valid
  
  # validate that steps that have been passed remain passing
  for status in STATUS_LIST
    unless status == "awaiting_submission"
      validate Proc.new { |key| key.can_be_set_to?(status.to_sym) },
               if: Proc.new { |key| key.at_stage?(status.to_sym, true) }
    end
  end
  
  # Scopes
  scope :by_user, -> { joins(:user).order("andrew_id") }
  scope :chronological, -> { order(time_submitted: :desc).order(time_filtered: :desc).order(time_confirmed: :desc).order(time_expired: :desc) }
  scope :active, -> { where(active: true) }
  
  #scopes dealing with status for dashboards
  scope :awaiting_filters, -> { where("status == ?", 'awaiting_filters')}
  scope :awaiting_confirmation, -> { where("status == ?", 'awaiting_confirmation')}
  scope :confirmed, -> { where("status == ?", 'confirmed')}
  scope :awaiting_submission, -> { where("status == ?", 'awaiting_submission')}
  scope :submitted, -> { where("status <> 'awaiting_submission'") }
  scope :expired, -> { where("time_expired < ?", DateTime.now)}
  scope :not_expired, -> { where("time_expired >= ?", DateTime.now) }
  scope :find_by_id, ->(param_id) { where("id == ?", param_id) }
  

  #scopes that will be used for email jobs 
  #FIXME figure out why month scope isn't working  
  scope :expires_in_a_month, -> { where("time_expired LIKE ?","%#{30.days.from_now.to_date}%") }
  
  scope :expires_today, -> { where("time_expired LIKE ?","%#{Date.today}%") }

  # Methods
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
  
  def expired?
    return false if self.time_expired.nil?
    return self.time_expired < Date.today
  end
  
  # The form is ready to be submitted by the requester, or approved, or confirmed?
  def can_be_set_to? sym
    case sym # Do false cases first
    when :awaiting_filters
      # Each proposal_text_thing (except number 8) is not blank, name is not blank, terms agreed to
      TEXT_FIELD_LIST.each {|attr|  return false if self.send(attr).blank? and attr != :proposal_text_eight}
      return false if (self.name.blank? or !self.agree)
    when :awaiting_confirmation
      return false if self.time_expired.nil?
    when :confirmed 
      # Simply counting all approvers and comparing approvals already earned
      # would have a bug when someone approves it but is soon demoted from approver.
      # So, only find the number of approvers who are currently still active "approvers"
      return false if !(self.approval_users.approvers_only.size == User.approvers_only.size)
    end
    return true
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

  # Used for index and show pages; overwrites displayed name if name is blank 
  # Note that this method is overwriting the :name attribute getter.
  def display_name
    if name.blank? # No name given yet, make up a temporary one
      return "Unnamed Application"
    else
      return name
    end
  end
  
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
      salt = SETTINGS[:default]["api_key_salt"].split("")
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
    if at_stage? :awaiting_submission and self.can_be_set_to? :awaiting_filters
      self.status = "awaiting_filters"
      set_time_to_now(:time_submitted)
      save_changes
      return true
    end
    errors.add(:user_key, "cannot be submitted. Please check that you
               have completed all fields of the form and agreed to API usage terms")
    return false
  end
  
  # When an admin submits the filter form so it can be approved by everyone.
  # Require an expiration date and at least one filter at this stage
  def set_key_as_filtered
    if at_stage? :awaiting_filters and self.can_be_set_to? :awaiting_confirmation
      self.status = "awaiting_confirmation"
      set_time_to_now(:time_filtered)
      save_changes
      return true
    end
    errors.add(:user_key, "needs an expiration date")
    return false
  end
  
  # When a key has been approved by everyone and is confirmed by admin
  def set_key_as_confirmed
    if at_stage? :awaiting_confirmation and self.can_be_set_to? :confirmed
      self.status = "confirmed"
      set_time_to_now(:time_confirmed)
      save_changes
      return true
    end
    errors.add(:user_key, "has not been approved by everyone yet")
    return false
  end
  
  # This is for Reset, when a key has rejected and sent back to the requester
  # Can only be sent back after submission but before "confirmed" stage
  # Note: a key can only be reset if it has comments made by admin for the requester's benefit.
  def set_key_as_awaiting_submission
    if (at_stage? :awaiting_filters or at_stage? :awaiting_confirmation) and has_public_comments?
      self.status = "awaiting_submission"
      reset_times
      reset_approvals # Keep any filters/comments that were applied, so dont reset those
      save_changes
      return true
    end
    errors.add(:user_key, "cannot be reset without providing an Administrator note")
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
  
  # Callbacks
  # don't allow "Unnamed Application" to be the name; set to nil
  def check_name
    self.name = nil if self.name == "Unnamed Application"
  end
end
