class UserKeyFilter < ActiveRecord::Base
  belongs_to :filter
  belongs_to :user_key
end
