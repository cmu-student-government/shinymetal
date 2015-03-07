class Organization < ActiveRecord::Base
  has_many :user_key_organizations
  has_many :keys, through: :user_key_organizations
end
