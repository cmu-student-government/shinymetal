require 'test_helper'

class FilterTest < ActiveSupport::TestCase
  #Relationships
  should have_many(:whitelist_filters)
  should have_many(:whitelists).through(:whitelist_filters)

  context "Creating a filters context" do
    setup do
      create_filters
    end
    
    teardown do
      destroy_filters
    end

    should "have a method to return the filters name" do
      assert_equal "\"status\" = \"active\"", @organizations_status_active.name
    end
	
    should "have a scope to sort filters alphabetically" do
      assert_equal ["\"category\" = \"sports\"", "\"status\" = \"active\"", "\"status\" = \"inactive\"", "\"type\" = \"active\""], Filter.alphabetical.to_a.map {|f| f.name}
    end
    
    should "have a scope to restrict filter resources" do
      assert_equal [["positions", "\"type\" = \"active\""]],
                   Filter.alphabetical.restrict_to("positions").to_a.map {|f| [f.resource, f.name]}
    end
    
    should "have a method to test for invalid resource names" do
      bad_filter = FactoryGirl.build(:filter, filter_name: "bad")
      deny bad_filter.valid?
    end
    
    should "have a method to get all the user keys that use the filter" do
      assert_equal @organizations_status_active.user_keys, []
      create_users
      create_user_keys
      create_whitelists
      @organizations_status_active.reload
      assert_equal @organizations_status_active.user_keys.to_a.map{|o| o.name}, ["Bender Submitted"]
      destroy_whitelists
      destroy_user_keys
      destroy_users
    end
    
    should "not be destroyable when in use" do
      create_users
      create_user_keys
      create_whitelists
      deny @organizations_status_active.is_destroyable?
      unused_filter = FactoryGirl.create(:filter, filter_value: "A new, unused value")
      assert unused_filter.is_destroyable?
      unused_filter.destroy
      destroy_whitelists
      destroy_user_keys
      destroy_users
    end
    
  end
end
