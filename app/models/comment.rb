class Comment < ActiveRecord::Base
  # Relationships
  belongs_to :user_key
  belongs_to :comment_user, class_name: User, foreign_key: :user_id
  
  # Validations
  validates_presence_of :message, message: "cannot be blank."

  validate :user_key_id_valid
  validate :user_id_valid
  
  # Scope
  scope :chronological, -> { order(:created_at) }
  scope :public_only, -> { where(is_private: false) }
  scope :private_only, -> { where(is_private: true) }
  
  private
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