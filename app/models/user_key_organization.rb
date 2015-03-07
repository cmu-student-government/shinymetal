class UserKeyOrganization < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user_key
end
