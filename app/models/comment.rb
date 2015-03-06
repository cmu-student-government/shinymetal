class Comment < ActiveRecord::Base
  belongs_to :user_key
  belongs_to :user
  
  validates_presence_of :message, message: "Message cannot be blank."
  
  scope :chronological, -> { order(:time_posted) }
end
