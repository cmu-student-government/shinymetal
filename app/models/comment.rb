class Comment < ActiveRecord::Base
  # Relationships
  belongs_to :user_key
  belongs_to :comment_user, class_name: User, foreign_key: :user_id
  
  # Validations
  validates_presence_of :message, message: "cannot be blank."

  validate :user_key_id_valid
  # This second one has a helper method, has_valid_staff_user
  validate :user_id_valid
  
  # Scope
  scope :chronological, -> { order(:created_at) }
  scope :public_only, -> { where(is_private: false) }
  scope :private_only, -> { where(is_private: true) }
  
  # Only allow admins to post public comments;
  # The only purposes of comments are for admins to tell requesters what to change,
  # or for staff to discuss a key privately; Requesters should not make comments.
  
  private
  def has_valid_staff_user
    # User can always be admin
    user = User.find(self.user_id)
    if user.role? :admin
      return true
    elsif user.role? :is_staff
      # All staff can make private comments to each other
      if is_private
        return true
      else
        errors.add(:user_id, "is not an admin and cannot make public comments")
        return false
      end
    end
    # User must be requester, so not valid
    errors.add(:user_id, "is not a staffmember and cannot make comments")
    return false
  end
  
  # Foreign key validations
  def user_id_valid
    unless (User.all.to_a.map{|o| o.id}.include?(self.user_id) and has_valid_staff_user)
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