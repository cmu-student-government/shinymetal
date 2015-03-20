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
    	assert_equal ['AB Films', 'cmuTV', 'WRCT'], Organization.alphabetical.map { |o| o.name }
    end

  end
end
