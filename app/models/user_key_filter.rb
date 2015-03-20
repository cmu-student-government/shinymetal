class UserKeyFilter < ActiveRecord::Base
  belongs_to :filter
  belongs_to :user_key

  validate :filter_id_valid
  validate :user_key_id_valid
  
  private
  def user_key_id_valid
    unless UserKey.all.to_a.map{|o| o.id}.include?(self.user_key_id)
      errors.add(:user_key_id, "is invalid")
      return false
    end
    return true
  end
  
  def filter_id_valid
    unless Filter.all.to_a.map{|o| o.id}.include?(self.filter_id)
      errors.add(:filter_id, "is invalid")
      return false
    end
    return true
  end
end
