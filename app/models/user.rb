class User < ActiveRecord::Base
  has_many :user_keys

  scope :alphabetical, -> { order(:andrew_id) }
  scope :approvers, -> { where(is_approver: true) }
  scope :search, ->(param) { where("andrew_id LIKE '%#{param.to_s.downcase}%'") }

  ROLE_LIST = ["requester", "admin"]

  def is_admin?
    self.role == "admin"
  end
end
