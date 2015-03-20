class Approval < ActiveRecord::Base
  # Relationships
  belongs_to :approval_user, class_name: User, foreign_key: :user_id
  belongs_to :user_key
  
  # Validations
  validates :user_key_id, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :user_id, presence: true, numericality: { greater_than: 0, only_integer: true }
  
  # Scopes
  scope :by, ->(user) { where(user_id: user.id) }
  
  # Methods
  # Every new approval is always unique
  validates_uniqueness_of :user_id, scope: :user_key_id
  validate :belongs_to_valid_approver, on: :create
  
  validate :user_key_id_valid
  validate :user_id_valid
  
  private
  # On create, should belong to an approver of some kind
  def belongs_to_valid_approver
    unless self.user_id.nil? or User.approvers_only.to_a.map{|o| o.id}.include?(self.user_id)
      errors.add(:approval_user, "is not a valid approver")
      return false
    end
    return true
  end
  
  def user_id_valid
    unless User.all.to_a.map{|o| o.id}.include?(self.user_id)
      errors.add(:user_id, "is invalid")
      return false
    end
    return true
  end
  
  def user_key_id_valid
    unless UserKey.all.to_a.map{|o| o.id}.include?(self.user_key_id)
      errors.add(:user_key_id, "is invalid")
      return false
    end
    return true
  end
end 
