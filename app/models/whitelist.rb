class Whitelist < ActiveRecord::Base
  # Relationships
  belongs_to :user_key, inverse_of: :whitelists
  has_many :whitelist_filters
  has_many :filters, through: :whitelist_filters
  
  validate :user_key_id_valid
  
  # Scopes
  scope :chronological, -> { order(:created_at) }
  scope :restrict_to, ->(param) { where(resource: param) }
  
  def display_name
    return "Whitelist for " + self.created_at.to_s
  end
  
  private
  def user_key_id_valid
    unless UserKey.all.to_a.map{|o| o.id}.include?(self.user_key_id)
      errors.add(:user_key_id, "is not a invalid user key")
      return false
    end
    return true
  end
end
