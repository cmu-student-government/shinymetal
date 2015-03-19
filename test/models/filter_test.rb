require 'test_helper'

class FilterTest < ActiveSupport::TestCase
  #Relationships
  should have_many(:user_key_filters)
  
  #Validations

  #Scopes and methods
  context "Creating a filters context" do
    setup do
      create_filters
    end
    
    teardown do
      destroy_filters
    end

    should "have a method to return the filters name" do
    	assert_equal "page : 1", @organizations_page_filter.name
    end
	
    should "have a scope to sort filters alphabetically" do
    	assert_equal ["page : 1", "page : 2", "status : inactive"], Filter.alphabetical.map {|f| f.name}
    end

  end
end
