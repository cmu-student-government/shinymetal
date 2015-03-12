require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:user)
  should belong_to(:user_key)

  #Validations
  should validate_presence_of(:message).with_message('Message cannot be blank.')

  #Scopes

  #Methods
end
