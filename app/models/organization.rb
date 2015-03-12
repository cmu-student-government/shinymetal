class Organization < ActiveRecord::Base
  # Relationships
  has_many :user_key_organizations
  has_many :user_keys, through: :user_key_organizations
  
  # Scopes
  #Revisit: We probably want case insensitive behavior for this
  scope :alphabetical, -> { order(:name) }
end
