# Connection between user key and column.
#  By existing, it shows that the user key has access to that column.
class UserKeyColumn < ActiveRecord::Base
  # Relationships
  
  belongs_to :column
  belongs_to :user_key
  
  # Validations
  
  validates_presence_of :column
  validates_presence_of :user_key
end
