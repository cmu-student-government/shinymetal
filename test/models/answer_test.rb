require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  should belong_to(:user_key)
  should belong_to(:question)
  
  should validate_presence_of(:user_key)
  should validate_presence_of(:question)
  
  context "Creating an answers context" do
    setup do
      create_users
      create_questions
      create_user_keys
      create_answers
    end
    
    teardown do
      destroy_answers
      destroy_user_keys
      destroy_questions
      destroy_users
    end
    
    should "have a default scope" do
      assert_equal ["No, I'm a college student.", "Great!"], Answer.all.map{|a| a.message}
    end
  end
end
