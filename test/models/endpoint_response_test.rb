require 'test_helper'

class EndpointResponseTest < ActiveSupport::TestCase
  context "Creating an endpoint response context" do
    setup do
      create_everything
      @user_key_response = EndpointResponse.new(@bender_key_submitted, endpoint: "organizations")
      @users_response = EndpointResponse.new(nil, endpoint: "users")
      @organizations_response = EndpointResponse.new(nil, endpoint: "organizations", page: "2")
      @bad_resource = EndpointResponse.new(nil, endpoint: "invalid!")
      @bad_page_number = EndpointResponse.new(nil, endpoint: "users", page: "3")
    end
    
    teardown do
      destroy_everything
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
      # Expected response for hit_api_endpoint({endpoint: "users"})
      expected_response =
	   {"pageNumber" => 1,
            "pageSize" => 2,
            "totalItems" => 4,
            "totalPages" => 2,
            "items" => [{"name" => "First Test Item", "organizationId" => 10},
                        {"name" => "Second Test Item", "organizationId" => 20}]
            }      
      assert_equal expected_response,
                   @users_response.to_hash
    end
    
    should "have a private restrict_columns method that keeps only the given columns" do
      assert_equal ["name","organizationId"], @organizations_response.columns.sort
      assert_equal ["organizationId"], @user_key_response.columns
    end
  end
end
