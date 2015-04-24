require 'test_helper'

class WhitelistFilterTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:whitelist)
  should belong_to(:filter)

  context "Creating a whitelist filters context" do
    setup do
      create_users
      create_filters
      create_user_keys
      create_whitelists
    end
    
    teardown do
      destroy_user_keys
      destroy_filters
      destroy_whitelists
      destroy_users
    end
    
    # Validations for foreign key ids
    should "not allow invalid filter_id" do
      bad = FactoryGirl.build(:whitelist_filter, whitelist: @bender_key_submitted_whitelist, filter_id: "something_invalid")
      deny bad.valid?
    end
    
    should "not allow invalid whitelist_id" do
      bad = FactoryGirl.build(:whitelist_filter, whitelist_id: "something_invalid", filter: @organizations_page_filter)
      deny bad.valid?
    end
  end
end
