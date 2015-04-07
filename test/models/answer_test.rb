require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  should belong_to(:user_key)
  should belong_to(:question)
  
  should validate_presence_of(:user_key)
  should validate_presence_of(:question)
  
  # Scopes
  default_scope { order(created_at: :desc) } 
end
