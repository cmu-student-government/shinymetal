require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:comment_user)
  should belong_to(:user_key)

  #Validations
  should validate_presence_of(:message).with_message('cannot be blank.')
  
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
    
    # Validations for foreign key ids
    should "not allow invalid user_id" do
      bad_comment = FactoryGirl.build(:comment, user_key: @bender_key_awaiting_conf, comment_user: @leela, user_id: "something_invalid")
      deny bad_comment.valid?
    end
    
    should "not allow invalid user_key_id" do
      bad_comment = FactoryGirl.build(:comment, user_key_id: "something_invalid", comment_user: @leela)
      deny bad_comment.valid?
    end
  end
end
