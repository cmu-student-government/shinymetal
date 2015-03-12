require 'test_helper'

class UserKeyOrganizationTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:organization)
  should belong_to(:user_key)

  #Validations
  #Scopes
  #Methods
end
