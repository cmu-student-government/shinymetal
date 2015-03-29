class User < ActiveRecord::Base
  # Relationships
  has_many :user_keys

  # Validations
  ROLE_LIST = ["requester", "admin", "staff_approver", "staff_not_approver"]

  validates :andrew_id, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLE_LIST, message: "is not a recognized role in system" }

  scope :alphabetical, -> { order(:andrew_id) }
  scope :approvers_only, -> { where("role = 'admin' or role = 'staff_approver'") }
  scope :staff_only, ->  { where("role <> 'requester'") }
  scope :requesters_only, ->  { where("role == 'requester'") }
  scope :search, ->(param) { where("andrew_id LIKE ?", "%#{param.to_s.downcase}%") }

  # Methods
  def owns?(user_key)
    return user_key.user.id == self.id
  end

  def role?(sym)
    case sym
      when :is_staff
        return !(self.role == "requester")
      when :is_approver
        return (self.role == "admin" || self.role == "staff_approver")
      when :requester
        return self.role == "requester"
      when :admin
        return self.role == "admin"
    end
  end
end
