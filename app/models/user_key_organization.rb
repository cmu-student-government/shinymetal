class UserKeyOrganization < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user_key

  # Require org id and user_key id to be in system
  validate :organization_id_valid
  validate :user_key_id_valid
  
  private
  def user_key_id_valid
    unless UserKey.all.to_a.map{|o| o.id}.include?(self.user_key_id)
      errors.add(:user_key_id, "is invalid")
      return false
    end
    return true
  end
  
  def organization_id_valid
    unless Organization.all.to_a.map{|o| o.id}.include?(self.organization_id)
      errors.add(:organization_id, "is invalid")
      return false
    end
    return true
  end
end
