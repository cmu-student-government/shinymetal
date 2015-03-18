class Comment < ActiveRecord::Base
  belongs_to :user_key
  belongs_to :comment_user, class_name: User, foreign_key: :user_id
  
  validates_presence_of :message, message: "Message cannot be blank."
  
  scope :chronological, -> { order(:created_at) }
end