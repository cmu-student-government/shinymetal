class User < ActiveRecord::Base
  # Relationships
  has_many :user_keys

  # Validations
  ROLE_LIST = ["requester", "admin"]

  validates :andrew_id, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLE_LIST, message: "is not a recognized role in system" }

  scope :alphabetical, -> { order(:andrew_id) }
  scope :approvers, -> { where(is_approver: true) }
  scope :search, ->(param) { where("andrew_id LIKE '%#{param.to_s.downcase}%'") }

  def is_admin?
    self.role == "admin"
  end

end
