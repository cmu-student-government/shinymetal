require 'test_helper'

class ApprovalTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:approval_user)
  should belong_to(:user_key)

  #Validations

  #Scopes
  context "Creating a user key context" do
    setup do
      create_everything
    end
    
    teardown do
      destroy_everything
    end
    
    should "have scope by user" do
      assert_equal [["bender", "confirmed"], ["bender", "awaiting_confirmation"]],
                   Approval.by(@leela).to_a.map{|a| [a.user_key.user.andrew_id, a.user_key.status ]}
      assert_equal 0, Approval.by(@bender).size
    end
  end
end
