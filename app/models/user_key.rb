class UserKey < ActiveRecord::Base
  # Relationships
  belongs_to :user
  has_many :user_key_organizations
  has_many :user_key_filters
  has_many :filters, through: :user_key_filters
  has_many :comments
  has_many :approvals
  
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
  
  # Methods
  def approved_by_all?
    return self.approvals.size == User.approvers.all.size
  end
  
  def at_submit_stage?
    return self.status == "awaiting_submission"
  end
  
  def at_filter_stage?
    return self.status == "awaiting_filters"
  end
  
  def at_confirmation_stage?
    return self.status == "awaiting_confirmation"
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
  
  # When a key has been approved by everyone and is confirmed by admin
  def set_key_as_confirmed
    if at_confirmation_stage?
      set_status_to("confirmed")
      set_time_to_now(:time_confirmed)
      save_changes
      return true
    end
    return false
  end

end
