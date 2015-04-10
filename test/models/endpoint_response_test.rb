require 'test_helper'

class EndpointResponseTest < ActiveSupport::TestCase
  context "Creating an endpoint response context" do
    setup do
      @users_response = EndpointResponse.new("users")
      @organizations_response = EndpointResponse.new("organizations", page_number: 2)
      @bad_resource = EndpointResponse.new("invalid!")
      @bad_page_number = EndpointResponse.new("users", page_number: 3)
    end
    
    should "have an expected fail response when the resource is invalid" do
      assert @bad_resource.failed
      deny @users_response.failed
    end
    
    should "have an expected fail response when the page number is invalid" do
      assert @bad_page_number.failed
    end
	
    should "have appropriate getters for pagesize, pagenumber, totalitems, totalpages, and items" do
      assert_equal 2, @organizations_response.page_size
      assert_equal 2, @organizations_response.page_number
      assert_equal 4, @organizations_response.total_items
      assert_equal 2, @organizations_response.total_pages
      assert_equal [{"name"=>"Third Test Item", "organizationId"=>30},
		    {"name"=>"Fourth Test Item", "organizationId"=>40}],
                   @organizations_response.items
    end
    
    should "have method to return a list of the columns available" do
      assert_equal ["name","organizationId"], @users_response.columns.sort
    end
    
    should "become a hash like collegiatelink hash with to_hash method" do
      assert_equal hit_api_endpoint("users"), @users_response.to_hash
    end
    
    should "have a restrict_to_columns method that keeps only the given columns" do
      @organizations_response.restrict_to_columns(["organizationId","name"])
      assert_equal ["name","organizationId"], @organizations_response.columns.sort
      @users_response.restrict_to_columns(["name", "dummy_value"])
      assert_equal ["name"], @users_response.columns
      @users_response.restrict_to_columns([])
      assert_equal [], @users_response.columns
    end
  end
end
