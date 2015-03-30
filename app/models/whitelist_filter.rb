class WhitelistFilter < ActiveRecord::Base
  belongs_to :filter
  belongs_to :whitelist

  validate :filter_id_valid
  validate :whitelist_id_valid
  
  private
  def whitelist_id_valid
    unless Whitelist.all.to_a.map{|o| o.id}.include?(self.whitelist_id)
      errors.add(:whitelist_id, "is invalid")
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
