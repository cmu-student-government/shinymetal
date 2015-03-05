class UserKey < ActiveRecord::Base
  # Relationships
  belongs_to :user
  has_many :user_key_organizations
  has_many :user_key_filters
  has_many :comments
  has_many :approvals
  
  # Methods
  def approved_by_all?
    return true
  end
end
