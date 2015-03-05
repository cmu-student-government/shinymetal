class UserKey < ActiveRecord::Base
  # Relationships
  belongs_to :user
  has_many :user_key_organizations
  has_many :user_key_filters
  has_many :comments
  has_many :approvals
  
  # Validations
  # Statuses for keys are currently:
  #     awaiting_submission, if started by requester but not submitted to admin
  #     awaiting_filters, if it hasn't had filters assigned
  #     awaiting_approval, if not approved by everybody
  # or  approved
  STATUS_LIST = ["awaiting_submission",
                 "awaiting_filters",
                 "awaiting_approval",
                 "approved"]
  
  validates_inclusion_of :status, in: STATUS_LIST
  
  # Scopes
  scope :by_user, -> { joins(:user).order(:andrew_id) }
  
  # Methods
  def approved_by_all?
    return true
  end
  
  # Called by controller when a key is submitted by requester to admin
  def set_key_as_submitted
    validate_status_is("awaiting_submission")
    set_status_to("awaiting_filters")
    set_time_to_now(:time_requested)
    save_changes
  end
  
  # Called by controller when an admin submits the filter form
  def set_key_as_filtered
    validate_status_is("awaiting_filters")
    set_status_to("awaiting_approval")
    set_time_to_now(:time_filtered)
    save_changes
  end
  
  private
  
  # Save changes to Ruby object to the database
  def save_changes
    self.save!
  end
  
  def validate_status_is(param_status)
    unless self.status == param_status
      errors.add(:status, "is not a valid status for that action")
      return false
    end
    return true
  end
  
  # When submitted, a key should be marked as ready for filters from admin
  # When filtered, a key should be marked as ready for approval
  def set_status_to(param_status)
    self.status = param_status
  end
  
  # When submitted, a key should have its requested date marked
  def set_time_to_now(param_time_attribute)
    self[param_time_attribute] = DateTime.now.in_time_zone("Pacific Time (US & Canada)")
  end
end
