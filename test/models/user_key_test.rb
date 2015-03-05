require 'test_helper'

class UserKeyTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:user)
  should have_many(:user_key_organizations)
  should have_many(:user_key_filters)
  should have_many(:comments)
  should have_many(:approvals)
  
  # Validations
  
  # Status
  should allow_value("awaiting_submission").for(:status)
  should allow_value("awaiting_filters").for(:status)
  should allow_value("awaiting_approval").for(:status)
  should allow_value("approved").for(:status)
  should_not allow_value("anything_else").for(:status)
  should_not allow_value(nil).for(:status)
  
  
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
    
    should "have a scope to sort by andrew_id" do
      assert_equal ["bender", "bender"], UserKey.by_user.all.map{|o| o.user.andrew_id}
    end
    
    should "have a scope to sort by time submitted" do
      assert_equal [["bender", DateTime.now.to_formatted_s(:pretty)]],
                   UserKey.by_user.by_time_submitted.all.map{|o| [o.user.andrew_id, o.time_submitted.to_formatted_s(:pretty)] }
    end
    
    should "have time_requested set to now when request is submitted" do
      assert @bender_key.time_submitted.nil?
      @bender_key.set_key_as("submitted")
      # Uses to_s formatting to test, since DateTime changes too quickly to be tested...
      @bender_key.reload
      assert_equal DateTime.now.to_formatted_s(:pretty),
                   @bender_key.time_submitted.to_formatted_s(:pretty)
    end
    
    should "have status changed when request is submitted" do
      assert_equal "awaiting_submission",
                   @bender_key.status
      @bender_key.set_key_as("submitted")
      # Reload to make sure changes were saved ot database
      @bender_key.reload
      assert_equal "awaiting_filters",
                   @bender_key.status
    end
    
    should "have time_filtered set to now when request is set as filtered by admin" do
      assert @bender_key_submitted.time_filtered.nil?
      @bender_key_submitted.set_key_as("filtered")
      #uses to_s to test, since DateTime changes too quickly to be tested...
      @bender_key_submitted.reload
      assert_equal DateTime.now.to_formatted_s(:pretty),
                   @bender_key_submitted.time_filtered.to_formatted_s(:pretty)
    end
    
    should "have status changed when request is filtered" do
      assert_equal "awaiting_filters",
                   @bender_key_submitted.status
      @bender_key_submitted.set_key_as("filtered")
      # Reload to make sure changes were saved ot database
      @bender_key_submitted.reload
      assert_equal "awaiting_approval",
                   @bender_key_submitted.status
    end
    
    should "not allow submission-ready key to be set as filtered too early" do
      # Try and fail to set key as filtered
      deny @bender_key.set_key_as("filtered")
      assert_equal "awaiting_submission",
                   @bender_key.status
    end
    
    should "not allow approval-ready key to be set as submitted again" do
      # Try and fail to set it as approved
      deny @bender_key_submitted.set_key_as("submitted")
      assert_equal "awaiting_filters",
                   @bender_key_submitted.status
    end
  end
end
