class UserKeyColumn < ActiveRecord::Base
  belongs_to :column
  belongs_to :user_key
  
  validates_presence_of :column
  validates_presence_of :user_key
end
