require 'test_helper'

class UserKeyOrganizationTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:organization)
  should belong_to(:user_key)

  #Validations from chess camp lol
  should validate_presence_of(:organization_id)
  should validate_presence_of(:user_key_id)
  should validate_numericality_of(:organization_id)
  should validate_numericality_of(:user_key_id)
  should_not allow_value(-1).for(:organization_id)
  should_not allow_value(0).for(:organization_id)
  should_not allow_value(50.50).for(:organization_id)
  should_not allow_value(-1).for(:user_key_id)
  should_not allow_value(0).for(:user_key_id)
  should_not allow_value(50.50).for(:user_key_id)
  
end
