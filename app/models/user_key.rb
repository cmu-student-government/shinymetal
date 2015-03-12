class UserKey < ActiveRecord::Base
  # Relationships
  belongs_to :user
  has_many :user_key_organizations
  has_many :user_key_filters
  has_many :filters, through: :user_key_filters
  has_many :organizations, through: :user_key_organizations
  has_many :users, through: :approvals
  has_many :comments
  has_many :approvals
  
  accepts_nested_attributes_for :comments
  
  # Validations
  # Statuses for keys are currently:
  #     awaiting_submission, if started by requester but not submitted to admin
  #     awaiting_filters, if it hasn't had filters assigned
  #     awaiting_confirmation, if not approved by everybody
  # or  confirmed
  STATUS_LIST = ["awaiting_submission",
                 "awaiting_filters",
                 "awaiting_confirmation",
                 "confirmed"]
  
  validates_inclusion_of :status, in: STATUS_LIST
  
  # Scopes
  scope :by_user, -> { joins(:user).order("andrew_id") }
  scope :by_time_submitted, -> { where("time_submitted IS NOT NULL").order(time_submitted: :desc) }
  
  #scopes dealing with status for dashboards
  scope :awaiting_filters, -> { where("status LIKE ?", 'awaiting_filters')}
  scope :awaiting_confirmation, -> { where("status LIKE ?", 'awaiting_confirmation')}
  scope :confirmed, -> {where("status LIKE ?", 'confirmed')}
  scope :awaiting_submission, -> {where("status LIKE ?", 'awaiting_submission')}

  scope :expired, -> {where("time_expired < ?", DateTime.now)}
  
  # Methods
  
  # Simply counting all approvers and comparing approvals already earned
  # would have a bug when someone approves it but is soon demoted from approver.
  # So, only find the number of approvers who are currently still approvers
  def approved_by_all?
    return self.users.approvers.size == User.approvers.all.size
  end
  
  def at_submit_stage?
    return self.status == "awaiting_submission"
  end
  
  def at_filter_stage?
    return self.status == "awaiting_filters"
  end
  
  def at_confirm_stage?
    return self.status == "awaiting_confirmation"
  end
  
  def confirmed?
    return self.status == "confirmed"
  end
  
  def name
    "Application Key #{self.id}" 
  end
  
  def set_key_as(param_status)
    case param_status
    when "submitted"
      return set_key_as_submitted
    when "filtered"
      return set_key_as_filtered
    when "confirmed"
      return set_key_as_confirmed
    end
  end
  
  private
  # Save changes to Ruby object to the database
  def save_changes
    self.save!
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

  # When a key is submitted by requester to admin
  def set_key_as_submitted
    if at_submit_stage?
      set_status_to("awaiting_filters")
      set_time_to_now(:time_submitted)
      save_changes
      return true
    end
    return false
  end
  
  # When an admin submits the filter form so it can be approved by everyone
  def set_key_as_filtered
    if at_filter_stage?
      set_status_to("awaiting_confirmation")
      set_time_to_now(:time_filtered)
      save_changes
      return true
    end
    return false
  end
  
  def set_key_value
    # NEEDS SOME HASHING ALGORITHM FOR UNIQUE KEY VALUES
    self.value = "SECURE HASH VALUE!"
  end
  
  # When a key has been approved by everyone and is confirmed by admin
  def set_key_as_confirmed
    if at_confirm_stage?
      set_status_to("confirmed")
      set_time_to_now(:time_confirmed)
      set_key_value
      save_changes
      return true
    end
    return false
  end

end
