require 'test_helper'

class UserKeyFilterTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:filter)
  should belong_to(:user_key)

  context "Creating a organizations context" do
    setup do
      create_organizations
    end
    
    teardown do
      destroy_organizations
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
