require 'test_helper'

class UserKeyOrganizationTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:organization)
  should belong_to(:user_key)

  context "Creating a organizations context" do
    setup do
      create_everything
    end
    
    teardown do
      destroy_everything
    end

    # Validations for foreign key ids
    should "not allow invalid organization_id" do
      bad_key_org = FactoryGirl.build(:user_key_organization, user_key: @bender_key_submitted, organization_id: "something_invalid")
      deny bad_key_org.valid?
    end
    
    should "not allow invalid user_key_id" do
      bad_key_org = FactoryGirl.build(:user_key_organization, user_key_id: "something_invalid", organization: @cmutv)
      deny bad_key_org.valid?
    end
  end
end
