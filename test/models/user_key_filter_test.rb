require 'test_helper'

class UserKeyFilterTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:filter)
  should belong_to(:user_key)

  context "Creating a user key filters context" do
    setup do
      create_users
      create_filters
      create_user_keys
      create_user_key_filters
    end
    
    teardown do
      destroy_user_key_filters
      destroy_user_keys
      destroy_filters
      destroy_users
    end
    
    # Validations for foreign key ids
    should "not allow invalid filter_id" do
      bad_key_filter = FactoryGirl.build(:user_key_filter, user_key: @bender_key_submitted, filter_id: "something_invalid")
      deny bad_key_filter.valid?
    end
    
    should "not allow invalid user_key_id" do
      bad_key_filter = FactoryGirl.build(:user_key_filter, user_key_id: "something_invalid", filter: @organizations_page_filter)
      deny bad_key_filter.valid?
    end
  end
end
