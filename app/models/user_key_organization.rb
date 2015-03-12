class UserKeyOrganization < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user_key

  validates :organization_id, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :user_key_id, presence: true, numericality: { greater_than: 0, only_integer: true }

end
