require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:user)
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
    	assert_equal Comment.chronological, Comment.all.sort_by {|c| c.time_posted}
    end

    #Methods
    #NEED TO COME BACK TO THIS TEST CALLBACK STUFF TOO	
    should "have a method to set the time posted to now" do
      # @a_comment = FactoryGirl.build(:comment)
      # @a_comment.update_attribute(:time_posted, 10.minutes.ago)
      # assert_equal 10.minutes.ago, @a_comment.time_posted
      # @a_comment.save!
      # assert_equal DateTime.now,@a_comment.time_posted
    end

  end

  
end
