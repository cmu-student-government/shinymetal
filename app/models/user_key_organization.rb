# Connection between user key and organization.
#  By existing, it shows that the user key has access to that organization.
class UserKeyOrganization < ActiveRecord::Base
  # Relationships
  
  belongs_to :organization
  belongs_to :user_key
  
  # Validations

  validates_presence_of :user_key
  validates_presence_of :organization
  validates_uniqueness_of :user_key_id, scope: :organization_id
end
