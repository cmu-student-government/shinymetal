require 'test_helper'

class ApprovalTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:approval_user)
  should belong_to(:user_key)

  #Validations
  should validate_uniqueness_of(:user_id).scoped_to(:user_key_id)

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
    
    should "be made by an approver on create" do
      # Bender is not an approver
      @bad_approval = FactoryGirl.build(:approval, user_key: @bender_key_submitted, approval_user: @bender)
      #deny @bad_approval.valid?
    end
    
        # Validations for foreign key ids
    should "not allow invalid user_id" do
      bad_comment = FactoryGirl.build(:approval, user_key: @bender_key_awaiting_conf, approval_user: @leela, user_id: "something_invalid")
      deny bad_comment.valid?
    end
    
    should "not allow invalid user_key_id" do
      bad_comment = FactoryGirl.build(:approval, user_key_id: "something_invalid", approval_user: @leela)
      deny bad_comment.valid?
    end
  end
end
