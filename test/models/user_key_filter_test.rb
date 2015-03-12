require 'test_helper'

class UserKeyFilterTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:filter)
  should belong_to(:user_key)

  #Validations from chess camp lol
  should validate_presence_of(:filter_id)
  should validate_presence_of(:user_key_id)
  should validate_numericality_of(:filter_id)
  should validate_numericality_of(:user_key_id)
  should_not allow_value(-1).for(:filter_id)
  should_not allow_value(0).for(:filter_id)
  should_not allow_value(50.50).for(:filter_id)
  should_not allow_value(-1).for(:user_key_id)
  should_not allow_value(0).for(:user_key_id)
  should_not allow_value(50.50).for(:user_key_id)

end
