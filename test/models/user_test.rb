require 'test_helper'

class UserTest < ActiveSupport::TestCase
  #Relationships
  should have_many(:user_keys)

  #Validations
  should validate_presence_of(:andrew_id)

  should allow_value("admin").for(:role)
  should allow_value("requester").for(:role)
  should allow_value("staff_approver").for(:role)
  should allow_value("staff_not_approver").for(:role)
  should_not allow_value("zoidberg").for(:role)
  should_not allow_value(10).for(:role)
  should_not allow_value(nil).for(:role)

  context "Creating a users context" do
    setup do
      create_users
    end
    
    teardown do
      destroy_users
    end
	
	#Scopes
    should "have a scope to sort users alphabetically" do
    	assert_equal ["bender", "fry", "leela", "zoidberg"], User.alphabetical.map {|u| u.andrew_id}
    end

    should "have a scope to return a list of approvers" do
    	assert_equal ["fry", "leela"], User.approvers_only.alphabetical.map {|u| u.andrew_id}
    end

    should "have a scope to search for a given user" do
    	assert_equal ["leela"], User.search('leela').map{|u| u.andrew_id}
    	assert_equal ["bender"], User.search('bender').map{|u| u.andrew_id}
    	assert_equal ["fry"], User.search('fry').map{|u| u.andrew_id}
    	assert_equal ["zoidberg"], User.search('zoid').map{|u| u.andrew_id}
    end

  end

end
