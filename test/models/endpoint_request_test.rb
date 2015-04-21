require 'test_helper'

class EndpointRequestTest < ActiveSupport::TestCase
  # Note that for ease of testing, these tests use @bender_key_submitted for checking whitelists.
  # In reality, @bender_key_submitted has not been confirmed and would never make it this far in the request process.
  context "Creating an endpoint request context" do
    setup do
      create_everything
    end
    
    teardown do
      destroy_everything
    end
    
    should "have methods to get the options and resource" do
      users_request = EndpointRequest.new(@bender_key_submitted, "users", {"page" => "2", "status" => "active"})
      assert_equal 2, users_request.options.keys.size
      assert_equal "2", users_request.options["page"]
      assert_equal "active", users_request.options["status"]
      assert_equal "users", users_request.resource
    end
    
    should "show that a request is valid when 1 of its 2 whitelists is matched in organizations" do
      orgs_request = EndpointRequest.new(@bender_key_submitted, "organizations", {"page" => "2", "category" => "sports", "status" => "inactive"})
      assert orgs_request.valid?
      orgs_request = EndpointRequest.new(@bender_key_submitted, "organizations", {"status" => "active"})
      assert orgs_request.valid?
    end
    
    should "show that a request works for another endpoint, positions" do
      pos_request = EndpointRequest.new(@bender_key_submitted, "positions", {"page" => "2", "type" => "active"})
      assert pos_request.valid?
    end
    
    should "show that a request is invalid when no whitelist is matched" do
      # Not matching any part of any whitelist
      pos_request = EndpointRequest.new(@bender_key_submitted, "positions", {"page" => "2", "type" => "inactive"})
      deny pos_request.valid?
      # Not matching all parts of a whitelist
      orgs_request = EndpointRequest.new(@bender_key_submitted, "organizations", {"page" => "1", "category" => "sports"})
      deny orgs_request.valid?
    end
	
    should "show that a request is valid when it matches an organization" do
      pos_request = EndpointRequest.new(@bender_key_submitted, "positions", {"organizationId" => @cmutv.external_id.to_s })
      assert pos_request.valid?
    end
    
    should "show that a request is invalid when it has the wrong organization" do
      pos_request = EndpointRequest.new(@bender_key_submitted, "positions", {"organizationId" => @wrct.external_id.to_s })
      deny pos_request.valid?
    end
    
    should "show that a request is valid when no whitelists exist for the resource" do
      # @bender_key_confirmed has no whitelists
      users_request = EndpointRequest.new(@bender_key_confirmed, "users", {"page" => "2", "status" => "active"})
      assert users_request.valid?
    end
  end
end
