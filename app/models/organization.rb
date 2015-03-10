class Organization < ActiveRecord::Base
  # Relationships
  has_many :user_key_organizations
  has_many :keys, through: :user_key_organizations
  
  # Scopes
  scope :alphabetical, -> { order(:name) }
end
