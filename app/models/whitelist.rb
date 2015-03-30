class Whitelist < ActiveRecord::Base
  belongs_to :user_key
  has_many :whitelist_filters
  has_many :filters, through: :whitelist_filters
  
  validate :user_key_id_valid
  
  private
  def user_key_id_valid
    unless UserKey.all.to_a.map{|o| o.id}.include?(self.user_key_id)
      errors.add(:user_key_id, "is invalid")
      return false
    end
    return true
  end
end
