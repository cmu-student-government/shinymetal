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
    
    should "have a scope to get only public comments" do
      assert_equal "I love APIs so much", Comment.public_only.to_a.first.message
    end
    
    should "have a scope to get only private comments" do
      assert_equal "Kiss my shiny metal API", Comment.private_only.to_a.first.message
    end
    
    # Validation for valid user
    should "fail when is built with a requester user" do
      bad_comment = FactoryGirl.build(:comment, user_key: @bender_key_awaiting_conf, comment_user: @bender )
      deny bad_comment.valid?
    end
    
    should "fail when is built with a staff user and is public" do
      bad_comment = FactoryGirl.build(:comment, user_key: @bender_key_awaiting_conf, comment_user: @leela, public: true)
      deny bad_comment.valid?
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
