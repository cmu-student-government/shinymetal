require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  # Relationships
  should have_many(:answers)
  should have_many(:user_keys).through(:answers)
  
  # Validations
  should validate_presence_of(:message)
  
  context "Creating a questions context" do
    setup do
      create_questions
    end
    
    teardown do
      destroy_questions
    end
    
    should "have chronological scope" do
      assert_equal ["How do you feel?", "Wassup?", "Got any money?"], Question.chronological.map{|q| q.message}
    end
    
    should "have active scope" do
      assert_equal ["How do you feel?", "Wassup?"], Question.active.map{|q| q.message}
    end
    
    should "have inactivate method" do
      assert @question_required.active
      @question_required.inactivate
      @question_required.reload
      deny @question_required.active
    end
  end
end
