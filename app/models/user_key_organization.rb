class UserKeyOrganization < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user_key

  # Require org id and user_key id to be in system
  validates_presence_of :user_key
  validates_presence_of :organization
  
  validates_uniqueness_of :user_key_id, scope: :organization_id
end
