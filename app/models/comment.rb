class Comment < ActiveRecord::Base
  # Relationships
  
  belongs_to :user_key
  belongs_to :comment_user, class_name: User, foreign_key: :user_id
  
  # Validations
  
  validates_presence_of :message, message: "cannot be blank."
  validates_presence_of :user_key
  validates_presence_of :comment_user
  # Comments are never edited, so this check is only done on: :create,
  #   which avoids the problem of when a commenter is demoted to requester.
  validate :has_valid_staff_user, on: :create
  
  # Scopes
  
  # These scopes are used in the views.
  scope :chronological, -> { order(:created_at) }
  # This scope is also used for reset validations in the user key model.
  scope :public_only, -> { where(public: true) }
  scope :private_only, -> { where(public: false) }
  
  private
  # Checks that the user is allowed to make a comment. Only allow admins to post public comments.
  #   The only purposes of comments are for admins to tell requesters what to change,
  #   or for staff to discuss a key privately; Requesters should not make comments.
  #
  # @return [Boolean] True iff this user is allowed to make this public or private comment.
  # @note Adds an error if it returns false.
  def has_valid_staff_user
    user = User.find_by id: self.user_id
    return true unless user
    # Admins can make any kind of comment.
    if user.role? :admin
      return true
    elsif user.role? :is_staff
      # All staff can make private comments to each other.
      if !(public)
        return true
      else
        errors.add(:base, "You are not an admin and cannot post public comments.")
        return false
      end
    end
    # User must be requester, so not valid
    errors.add(:base, "You are not a staffmember and cannot post any comments.")
    return false
  end
end