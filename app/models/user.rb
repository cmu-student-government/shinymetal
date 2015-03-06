class User < ActiveRecord::Base
  has_many :user_keys
  
  ROLE_LIST = ["requester", "admin"]
end
