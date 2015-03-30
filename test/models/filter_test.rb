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
      assert_equal "status : active", @organizations_page_filter.name
    end
	
    should "have a scope to sort filters alphabetically" do
      assert_equal ["category : sports", "status : active", "status : inactive", "type : active"], Filter.alphabetical.to_a.map {|f| f.name}
    end
    
    should "have a scope to restrict filter resources" do
      assert_equal [["positions", "type : active"]],
                   Filter.alphabetical.restrict_to("positions").to_a.map {|f| [f.resource, f.name]}
    end
    should "have a method to test for invalid resource names" do
      bad_filter = FactoryGirl.build(:filter, filter_name: "bad")
      deny bad_filter.valid?
    end
  end
end
