class Question < ActiveRecord::Base
  # Relationships
  has_many :answers
  has_many :user_keys, through: :answers
  
  # Validations
  validates_presence_of :message
  
  # Scopes
  scope :active, -> {where(active: true)}
  scope :chronological, -> {order(:created_at)}
  
  # Methods
  def inactivate
    self.update_attribute(:active, false)
  end
end
