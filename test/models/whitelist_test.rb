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
      create_whitelists
    end
    
    teardown do
      destroy_user_keys
      destroy_whitelists
      destroy_users
    end
    
    # Validations for foreign key ids
    should "not allow invalid user id" do
      bad = FactoryGirl.build(:whitelist, user_key_id: "something invalid")
      deny bad.valid?
    end
  end
end
