# The approval for a key; just by existing, it reflects that its
#   associated user approved its associated key. 
class Approval < ActiveRecord::Base
  # Relationships
  
  belongs_to :approval_user, class_name: User, foreign_key: :user_id
  belongs_to :user_key
  
  # Validations
  
  validates_presence_of :user_key
  validates_presence_of :approval_user
  
  # Every new approval is always unique.
  #   However, this validation is never actually needed, since the user key methods checks
  #   for this already.
  validates_uniqueness_of :user_id, scope: :user_key_id
  
  # This validation only needs to be run on: :create because Approvals are never updated,
  #   which avoids the problem of an approval belonging to a user who is demoted.
  validate :belongs_to_valid_approver, on: :create
  
  # Scopes
  
  # This scope is used by the user key model and user key controller to find existing Approvals.
  scope :by, ->(user) { where(user_id: user.id) }
  
  # Methods

  private
  # Checks that the Approval, on create, should belong to an admin or staff_approver.
  #
  # @return [Boolean] True iff the associated user is an approver.
  # @note Adds an error if it returns false.
  def belongs_to_valid_approver
    user = User.find_by id: self.user_id
    unless user.nil? or user.role? :is_approver
      errors.add(:base, "You are not a valid approver in the system.")
      return false
    end
    return true
  end
end 
