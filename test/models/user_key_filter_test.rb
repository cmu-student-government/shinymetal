require 'test_helper'

class UserKeyFilterTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:filter)
  should belong_to(:user_key)

  #Validations
  #Scopes
  #Methods
end
