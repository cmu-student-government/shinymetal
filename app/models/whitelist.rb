class Whitelist < ActiveRecord::Base
  # Relationships
  belongs_to :user_key, inverse_of: :whitelists
  has_many :whitelist_filters
  has_many :filters, through: :whitelist_filters
  
  validates_presence_of :user_key
  
  validate :has_filters
  
  # Scopes
  scope :chronological, -> { order(:created_at) }
  scope :restrict_to, ->(param) { where(resource: param) }
  
  private
  def has_filters
    if self.filters.empty?
      errors.add(:whitelist_id, "does not have any filters checked")
      return false
    end
    return true
  end
  
  def user_key_id_valid
    unless UserKey.all.to_a.map{|o| o.id}.include?(self.user_key_id)
      errors.add(:user_key_id, "is not a invalid user key")
      return false
    end
    return true
  end
end
