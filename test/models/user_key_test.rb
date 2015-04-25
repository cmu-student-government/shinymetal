require 'test_helper'

class UserKeyTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:user)
  should have_many(:user_key_organizations)
  should have_many(:whitelists)
  should have_many(:organizations).through(:user_key_organizations)
  should have_many(:comments)
  should have_many(:approvals)
  should have_many(:approval_users).through(:approvals)
  should have_many(:comment_users).through(:comments)

  # Validations
  should accept_nested_attributes_for(:comments).limit(1)
  should accept_nested_attributes_for(:answers)
  should accept_nested_attributes_for(:whitelists).allow_destroy(true)

  # Status
  should allow_value("awaiting_submission").for(:status)
  should allow_value("awaiting_filters").for(:status)
  should allow_value("awaiting_confirmation").for(:status)
  should allow_value("confirmed").for(:status)
  should_not allow_value("anything_else").for(:status)
  should_not allow_value(nil).for(:status)

  context "Creating a user key context" do
    setup do
      create_everything
    end

    teardown do
      destroy_everything
    end

    should "have a scope to sort by andrew_id" do
      assert_equal 9, UserKey.by_user.size
      assert_equal ["brodriguez", "hconrad"], UserKey.by_user.all.map{|o| o.user.andrew_id}.uniq
    end

    should "have assert scope to return only submitted keys" do
      assert_equal 4, UserKey.submitted.size
    end

    should "have a display_name method" do
      assert_equal "Bender Key", @bender_key.display_name
      @bender_key.name = nil
      @bender_key.save!
      @bender_key.reload
      assert_equal "Unnamed Application", @bender_key.display_name
    end

    should "have a method to search for a given key, even with incomplete input" do
      assert_includes UserKey.search('herm').map{ |u| u.name }, "Hermes Key"
    end

    should "have at_stage? method" do
      # Test some positive cases
      assert @bender_key.at_stage? :awaiting_submission
      assert @bender_key_submitted.at_stage? :awaiting_filters
      assert @bender_key_awaiting_conf.at_stage? :awaiting_confirmation
      assert @bender_key_confirmed.at_stage? :confirmed
      # Test negative cases
      deny @bender_key.at_stage? :awaiting_confirmation
      deny @bender_key_awaiting_conf.at_stage? :confirmed
      deny @bender_key_submitted.at_stage? :awaiting_submission
      # Test optional allow_past parameter
      assert @bender_key_submitted.at_stage?(:awaiting_submission, true)
      assert @bender_key_submitted.at_stage?(:awaiting_filters, true)
      assert @bender_key_awaiting_conf.at_stage?(:awaiting_filters, true)
      deny @bender_key_submitted.at_stage?(:awaiting_confirmation, true)
    end

    should "have a can_be_set_to? :confirmed method" do
      assert @bender_key_awaiting_conf_approved.can_be_set_to? :confirmed
      deny @bender_key_awaiting_conf.can_be_set_to? :confirmed
    end

    should "have an approved_by?(user) method" do
      assert @bender_key_awaiting_conf_approved.approved_by?(@leela)
      deny @bender_key_awaiting_conf_approved.approved_by?(@bender)
    end

    should "have method to undo set approved by a user" do
      assert @bender_key_awaiting_conf_approved.undo_set_approved_by(@leela)
      @bender_key_awaiting_conf_approved.reload
      # Don't allow double revoke.
      deny @bender_key_awaiting_conf_approved.undo_set_approved_by(@leela)
      # Show that the approval was revoked.
      deny @bender_key_awaiting_conf_approved.approved_by?(@leela)
    end

    should "have method to set approved by" do
      assert @bender_key_awaiting_conf.set_approved_by(@leela)
      @bender_key_awaiting_conf.reload
      # Don't allow double approval.
      deny @bender_key_awaiting_conf.set_approved_by(@leela)
      # Show that the approval was added.
      assert @bender_key_awaiting_conf.approved_by?(@leela)
    end

    # Test chronological filter, to be used on index pages
    should "have a scope to sort by time" do
      assert_equal ["Bender Submitted", "Bender Awaiting Conf",
                    "Bender Awaiting Conf Approved", "Bender Expires Today",
                    "Bender Expires in a Month",
                    "Bender Expired", "Bender Confirmed", "Bender Key"],
                   @bender.user_keys.chronological.all.map{|o| o.name }
    end

    should "have a scope that returns keys awaiting filters" do
      assert_equal 1, UserKey.awaiting_filters.size
    end

    should "have a scope that returns keys awaiting confirmation" do
      assert_equal 2, UserKey.awaiting_confirmation.size
    end

    should "have a scope that returns confirmed keys" do
      assert_equal 1, UserKey.confirmed.size
    end

    should "have a scope that returns keys awaiting submission" do
      assert_equal 5, UserKey.awaiting_submission.size
    end

    should "have a scope that returns expired keys" do
      assert_equal 2, UserKey.expired.size
    end

    should "have a scope that returns keys that expire in a month" do
      assert_equal 1, UserKey.expires_in_a_month.size
    end

    should "have a scope that returns keys that expire today" do
      assert_equal 1, UserKey.expires_today.size
    end

    should "have time_requested set to now when request is submitted" do
      assert @bender_key.time_submitted.nil?
      @bender_key.set_status_as :awaiting_filters
      # Uses to_s formatting to test, since DateTime changes too quickly to be tested...
      @bender_key.reload
      assert_equal DateTime.now.in_time_zone('Central Time (US & Canada)').to_formatted_s(:pretty),
                   @bender_key.time_submitted.to_formatted_s(:pretty)
    end

    should "have a method to show if the key will expire within 30 days" do
      deny @bender_key.will_expire_soon?
      assert @expires_in_month_key.will_expire_soon?
      deny @expired_key.will_expire_soon?
    end

    should "have status changed when request is submitted" do
      assert_equal "awaiting_submission",
                   @bender_key.status
      @bender_key.set_status_as :awaiting_filters
      # Reload to make sure changes were saved ot database
      @bender_key.reload
      assert_equal "awaiting_filters",
                   @bender_key.status
    end

    should "have time_filtered set to now when request is set as filtered by admin" do
      assert @bender_key_submitted.time_filtered.nil?
      # Set time_expired to allow the key to be marked as filtered
      @bender_key_submitted.time_expired = 2.days.from_now
      @bender_key_submitted.save!
      @bender_key_submitted.set_status_as :awaiting_confirmation
      #uses to_s to test, since DateTime changes too quickly to be tested...
      @bender_key_submitted.reload
      assert_equal DateTime.now.in_time_zone('Central Time (US & Canada)').to_formatted_s(:pretty),
                   @bender_key_submitted.time_filtered.to_formatted_s(:pretty)
    end

    should "have status changed when request is filtered" do
      assert_equal "awaiting_filters",
                   @bender_key_submitted.status
      # Set time_expired to allow the key to be marked as filtered
      @bender_key_submitted.time_expired = 2.days.from_now
      @bender_key_submitted.save!
      @bender_key_submitted.set_status_as :awaiting_confirmation
      # Reload to make sure changes were saved ot database
      @bender_key_submitted.reload
      assert_equal "awaiting_confirmation",
                   @bender_key_submitted.status
    end

    should "have status changed when request is confirmed" do
      assert_equal "awaiting_confirmation",
                   @bender_key_awaiting_conf_approved.status
      @bender_key_awaiting_conf_approved.set_status_as :confirmed
      # Reload to make sure changes were saved ot database
      @bender_key_awaiting_conf_approved.reload
      assert_equal "confirmed",
                   @bender_key_awaiting_conf_approved.status
    end

    should "not allow submission-ready key to be set as filtered too early" do
      # Try and fail to set key as filtered
      deny @bender_key.set_status_as :awaiting_confirmation
      assert_equal "awaiting_submission",
                   @bender_key.status
    end

    should "not allow approval-ready key to be set as submitted again" do
      # Try and fail to set it as submitted again
      deny @bender_key_submitted.set_status_as :awaiting_filters
      assert_equal "awaiting_filters",
                   @bender_key_submitted.status
    end

    should "not allow key without expiration date to be set as awaiting_confirmation" do
      # Try and fail to set it as submitted again
      deny @bender_key_submitted.set_status_as :awaiting_confirmation
      assert_equal "awaiting_filters",
                   @bender_key_submitted.status
    end

    should "not allow submission-ready key to be set as confirmed too early" do
      # Try and fail to set key as filtered
      deny @bender_key.set_status_as :awaiting_confirmation
      assert_equal "awaiting_submission",
                   @bender_key.status
    end

    should "not allow unapproved key to be set as confirmed" do
      # Try and fail to set key as filtered
      deny @bender_key_awaiting_conf.set_status_as :confirmed
      assert_equal "awaiting_confirmation",
                   @bender_key_awaiting_conf.status
    end

    should "not allow approved key to be set as reset" do
      # Try and fail to set key as reset
      deny @bender_key_confirmed.set_status_as :awaiting_submission
      assert_equal "confirmed",
                   @bender_key_confirmed.status
    end

    # Reset a key awaiting confirmation. Check that:
    # -Time is rest, approvals reset
    # -Admin comment remains
    # -Status changed correctly
    should "have a method to reset a key" do
      # Prove it had approvals and comments already
      assert_equal 2, @bender_key_awaiting_conf_approved.comments.size
      assert_equal 2, @bender_key_awaiting_conf_approved.approvals.size
      assert_equal "awaiting_confirmation",
                    @bender_key_awaiting_conf_approved.status
      @bender_key_awaiting_conf_approved.set_status_as :awaiting_submission
      # Reload to make sure changes were saved ot database
      @bender_key_awaiting_conf_approved.reload
      assert_equal "awaiting_submission",
                   @bender_key_awaiting_conf_approved.status
      # No approvals remaining; comments remain
      assert_equal 0, @bender_key_awaiting_conf_approved.approvals.size
      assert_equal 2, @bender_key_awaiting_conf_approved.comments.size
      # Time_filtered is reset
      assert @bender_key_awaiting_conf_approved.time_filtered.nil?
    end

    # Validations for foreign key ids
    should "not allow invalid user_id" do
      bad_key = FactoryGirl.build(:user_key, user_id: "invalid")
      deny bad_key.valid?
    end

    # Validating API key is properly generated
    should "have a gen_api_key method for confirmed keys" do
      key = @bender_key_confirmed
      # Algorithm used here mimics algorithm used in model
      date_string = key.time_submitted.to_s.split("")
      andrew_id = key.user.andrew_id.split("")
      salt = ENV["api_key_salt"].split("")
      hash_string = salt.zip(date_string, andrew_id).map{|a, b, c| c.nil? && b.nil? ? a : c.nil? ? a + b : a + b + c}.reduce(:+)
      # hash_string = date_string.zip(andrew_id).map{|a, b| b.nil? ? a : a + b}.reduce(:+)
      answer = Digest::SHA2.hexdigest hash_string
      assert_equal answer, key.gen_api_key
    end

    should "not have a gen_api_key method for non-confirmed keys" do
      expected = "A key will be generated upon approval."
      assert_equal expected, @bender_key.gen_api_key
      assert_equal expected, @bender_key_submitted.gen_api_key
      assert_equal expected, @bender_key_awaiting_conf.gen_api_key
    end

    should "have expired? method" do
      deny @bender_key.expired?
      @bender_key.time_expired = 1.day.from_now.to_date
      @bender_key.save!
      deny @bender_key.expired?
      assert @expired_key.expired?
    end

    should "not allow Unnamed Application name" do
      # Set name to nil if someone tries
      @bender_key.name = "Unnamed Application"
      @bender_key.save!
      @bender_key.reload
      assert @bender_key.name.nil?
    end

  end
end
