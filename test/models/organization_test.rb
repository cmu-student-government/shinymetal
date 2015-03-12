require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  #Relationships
  should have_many(:user_key_organizations)
  should have_many(:user_keys).through(:user_key_organizations)

  #Validations

  #Scopes

  #Methods
end
