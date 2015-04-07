require 'test_helper'

class UserTest < ActiveSupport::TestCase
  #Relationships
  should have_many(:user_keys)

  #Validations
  # This is not user input so it does't need to be validated
  #should validate_presence_of(:andrew_id)
  
  should allow_value("admin").for(:role)
  should allow_value("requester").for(:role)
  should allow_value("staff_approver").for(:role)
  should allow_value("staff_not_approver").for(:role)
  should_not allow_value("slurm").for(:role)
  should_not allow_value(10).for(:role)
  should_not allow_value(nil).for(:role)

  context "Creating a users context" do
    setup do
      create_everything
    end

    teardown do
      destroy_everything
    end

    #Scopes
    should "have a scope to sort users alphabetically by last, first" do
      assert_equal ["hconrad", "pjfry", "tleela", "brodriguez", "drzoid"], User.alphabetical.map {|u| u.andrew_id}
    end

    should "have a scope to sort users alphabetically by andrew" do
      assert_equal ["brodriguez", "drzoid", "hconrad", "pjfry", "tleela"], User.by_andrew.map {|u| u.andrew_id}
    end

    should "have a scope to return a list of approvers" do
      assert_equal ["pjfry", "tleela"], User.approvers_only.by_andrew.map {|u| u.andrew_id}
    end
    
    should "have a scope to return admin" do 
      assert_equal ["fry"], User.admin.map{|u| u.andrew_id}
    end

    should "have a method to get a user's name" do
      assert_equal "Phillip Fry", @fry.name
      assert_equal "Rodriguez, Bender", @bender.name(false)
    end

    should "have an owns? method" do
      assert @bender.owns? (@bender_key)
      deny @leela.owns? (@bender_key)
    end

    should "have a role? method for :requester and :admin" do
      # requester
      assert @bender.role? :requester
      deny @fry.role? :requester
      # admin
      deny @bender.role? :admin
      assert @fry.role? :admin
    end

    should "have a role? method for :is_staff and :is_approver" do
      # is_staff
      assert @leela.role? :is_staff
      assert @zoidberg.role? :is_staff
      assert @fry.role? :is_staff
      deny @bender.role? :is_staff
      # is_approver
      assert @leela.role? :is_approver
      deny @zoidberg.role? :is_approver
      assert @fry.role? :is_approver
      deny @bender.role? :is_approver
    end

    should "have a method to search for a given user, even with incomplete input" do
      assert_includes User.search('leela').map{ |u| u.andrew_id }, "tleela"
      assert_includes User.search('bender').map{ |u| u.andrew_id }, "brodriguez"
      assert_includes User.search('Fry').map{ |u| u.andrew_id }, "pjfry"
      assert_includes User.search('Doctor Zoi').map{ |u| u.andrew_id }, "drzoid"
    end
    
  end

end
