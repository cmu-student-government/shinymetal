class Approval < ActiveRecord::Base
  # Relationships
  belongs_to :approval_user, class_name: User, foreign_key: :user_id
  belongs_to :user_key
  
  # Validations
  validates_presence_of :user_key
  validates_presence_of :approval_user
  
  validate :belongs_to_valid_approver, on: :create
  
  # Scopes
  scope :by, ->(user) { where(user_id: user.id) }
  
  # Methods
  # Every new approval is always unique
  validates_uniqueness_of :user_id, scope: :user_key_id

  private
  # On create, should belong to an approver of some kind
  def belongs_to_valid_approver
    user = User.find_by id: self.user_id
    unless user.nil? or user.role? :is_approver
      errors.add(:base, "You are not a valid approver in the system.")
      return false
    end
    return true
  end
end 
