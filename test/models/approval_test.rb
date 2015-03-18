require 'test_helper'

class ApprovalTest < ActiveSupport::TestCase
  #Relationships
  should belong_to(:approval_user)
  should belong_to(:user_key)

  #Validations

  #Scopes
  context "Creating a user key context" do
    setup do
      create_everything
    end
    
    teardown do
      destroy_everything
    end
    
    should "have scope by user" do
      #test scope
    end
  end
end
