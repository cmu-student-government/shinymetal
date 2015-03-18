require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:comment_user)
  should belong_to(:user_key)

  #Validations
  should validate_presence_of(:message).with_message('Message cannot be blank.')
  
  context "Creating a comments context" do
    setup do
      create_everything
    end
    
    teardown do
      destroy_everything
    end
	
	#Scopes
    
    should "have a scope to sort chronologically" do
    	assert_equal Comment.chronological, Comment.all.sort_by {|c| c.created_at}
    end
  end
end
