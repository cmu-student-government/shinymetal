class User < ActiveRecord::Base
  has_many :user_keys
  
  scope :alphabetical, -> { order(:andrew_id) }
  
  ROLE_LIST = ["requester", "admin"]
end
