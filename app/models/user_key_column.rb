class UserKeyColumn < ActiveRecord::Base
  belongs_to :column
  belongs_to :user_key
  
  validate :column_id_valid
  validate :user_key_id_valid
  
  private
  def user_key_id_valid
    unless UserKey.all.to_a.map{|o| o.id}.include?(self.user_key_id)
      errors.add(:user_key_id, "is invalid")
      return false
    end
    return true
  end
  
  def column_id_valid
    unless Column.all.to_a.map{|o| o.id}.include?(self.column_id)
      errors.add(:column_id, "is invalid")
      return false
    end
    return true
  end
end
