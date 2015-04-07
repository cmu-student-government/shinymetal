require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  #Relationships
  should have_many(:user_key_organizations)
  should have_many(:user_keys).through(:user_key_organizations)

  #Validations

  #Scopes and methods
  context "Creating a organizations context" do
    setup do
      create_organizations
    end
    
    teardown do
      destroy_organizations
    end

    should "have a method to return the organizations alphabetically" do
      assert_equal ['AB Films', 'cmuTV', 'Inactive Org', 'WRCT'], Organization.alphabetical.map { |o| o.name }
    end
    
    should "have active scope" do
      assert_equal ['AB Films', 'cmuTV', 'WRCT'], Organization.alphabetical.active.map { |o| o.name }
    end
    
    should "have inactive scope" do
      assert_equal ['Inactive Org'], Organization.alphabetical.inactive.map { |o| o.name }
    end

    should "have class inactive_but_with_nonexpired_keys method to test for removed organizations" do
      assert_equal 0, Organization.inactive_but_with_nonexpired_keys.size
      create_users
      create_user_keys
      @bad_user_key_org = FactoryGirl.create(:user_key_organization, user_key: @bender_key_awaiting_conf, organization: @inactive_org)
      assert_equal ['Inactive Org'], Organization.inactive_but_with_nonexpired_keys.map{|o| o.name}
      destroy_users
      destroy_user_keys
      @bad_user_key_org.destroy
    end
  end
end
