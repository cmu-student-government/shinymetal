class User < ActiveRecord::Base
  # Relationships
  has_many :user_keys
  
  # Validations
  ROLE_LIST = ["requester", "admin", "staff_approver", "staff_not_approver"]

  validates :andrew_id, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLE_LIST, message: "is not a recognized role in system" }

  scope :alphabetical, -> { order(:andrew_id) }
  scope :approvers_only, -> { where("role = 'admin' or role = 'staff_approver'") }
  scope :search, ->(param) { where("andrew_id LIKE '%#{param.to_s.downcase}%'") }

end
