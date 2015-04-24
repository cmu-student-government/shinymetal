require 'test_helper'

class WhitelistTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:user_key)
  should have_many(:whitelist_filters)
  should have_many(:filters).through(:whitelist_filters)

  context "Creating a whitelist context" do
    setup do
      create_users
      create_user_keys
      create_filters
      create_whitelists
    end
    
    teardown do
      destroy_user_keys
      destroy_whitelists
      destroy_filters
      destroy_users
    end
    
    # Should have resource method
    should "have resource name method" do
      assert_equal "organizations", @bender_key_submitted_whitelist.resource
    end
    
    # Validations for foreign key ids
    should "not allow invalid user id" do
      bad = FactoryGirl.build(:whitelist, user_key_id: "something invalid")
      deny bad.valid?
    end
    
    # Validations for filter-less whitelists
    should "not allow filter-less whitelist" do
      # No filters
      bad = FactoryGirl.build(:whitelist, user_key: @bender_key_submitted)
      deny bad.valid?
    end
    
    # No duplications of filters for each whitelist
    should "not allow duplicated filters in whitelist" do
      current_filter = @bender_key_submitted_whitelist.filters.first
      bad = FactoryGirl.build(:whitelist_filter, filter: current_filter, whitelist: @bender_key_submitted_whitelist)
      deny bad.valid?
    end
    
    # Validations for filter-less whitelists
    should "not allow two filters with different resources" do
      # Bender Key's whitelist should only have organization filters
      valid_attendees_filter = FactoryGirl.create(:filter, resource: "attendees", filter_name: Resources::PARAM_NAME_HASH[:attendees][0])
      @bender_key_submitted_whitelist.filter_ids = @bender_key_submitted_whitelist.filter_ids << valid_attendees_filter.id
      deny @bender_key_submitted_whitelist.valid?
      valid_attendees_filter.destroy
    end
  end
end
