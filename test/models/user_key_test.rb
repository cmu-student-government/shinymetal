require 'test_helper'

class UserKeyTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:user)
  should have_many(:user_key_organizations)
  should have_many(:user_key_filters)
  should have_many(:comments)
  should have_many(:approvals)
  
  # test "the truth" do
  #   assert true
  # end
  context "Creating a user key context" do
    setup do
      create_everything
    end
    
    teardown do
      destroy_everything
    end
    
    should "have a method that indicates that the key has been approved by all approvers" do
      assert @bender_key.approved_by_all?
    end
  end
end
