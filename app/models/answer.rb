class Answer < ActiveRecord::Base
  # Relationship
  belongs_to :user_key
  belongs_to :question
  
  # Scopes
  # Using a default_scope makes it easier to sort nested items on create.
  default_scope { order(created_at: :desc) } 
  
  # Validations
  validates_presence_of :question
  validates_presence_of :user_key
end
