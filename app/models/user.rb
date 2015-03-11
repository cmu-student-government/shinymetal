class User < ActiveRecord::Base
  has_many :user_keys
  
  scope :alphabetical, -> { order(:andrew_id) }
  scope :approvers, -> { where(is_approver: true) }
  
  ROLE_LIST = ["requester", "admin"]
  
end
