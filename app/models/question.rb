# A question to be answered in the initial application form for a key.
class Question < ActiveRecord::Base
  # Relationships
  
  has_many :answers
  has_many :user_keys, through: :answers
  
  # Validations
  
  validates_presence_of :message
  
  # Scopes
  
  # An active question is one that will be used as part of future applications.
  scope :active, -> {where(active: true)}
  scope :chronological, -> {order(:created_at)}
  
  # Methods
  
  # Makes a question inactive.
  #   Inactivated questions are still available to the user keys that have answers to them already.
  #   They will not be available to future user keys.
  def inactivate
    self.update_attribute(:active, false)
  end
end
