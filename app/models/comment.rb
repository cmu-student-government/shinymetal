class Comment < ActiveRecord::Base
  before_save :set_time, on: :create
  
  belongs_to :user_key
  belongs_to :comment_user, class_name: User, foreign_key: :user_id
  
  validates_presence_of :message, message: "Message cannot be blank."
  
  scope :chronological, -> { order(:time_posted) }
  
  private
  
  def set_time
    self.time_posted = DateTime.now
  end
end
