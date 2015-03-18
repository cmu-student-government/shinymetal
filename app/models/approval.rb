class Approval < ActiveRecord::Base
  # Relationships
  belongs_to :approval_user, class_name: User, foreign_key: :user_id
  belongs_to :user_key
  
  # Methods
  scope :by, ->(user) { where(user_id: user.id) }
  
end
