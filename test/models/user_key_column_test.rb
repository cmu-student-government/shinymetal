require 'test_helper'

class UserKeyColumnTest < ActiveSupport::TestCase
  # Relationships
  should belong_to(:column)
  should belong_to(:user_key)
  
  context "Creating a user key columns context" do
    setup do
      create_users
      create_columns
      create_user_keys
      create_user_key_columns
    end
    
    teardown do
      destroy_user_key_columns
      destroy_user_keys
      destroy_columns
      destroy_users
    end
    
    # Validations for foreign key ids
    should "not allow invalid column_id" do
      bad_key_column = FactoryGirl.build(:user_key_column, user_key: @bender_key_submitted, column_id: "something_invalid")
      deny bad_key_column.valid?
    end
    
    should "not allow invalid user_key_id" do
      bad_key_column = FactoryGirl.build(:user_key_column, user_key_id: "something_invalid", column_id: @organizations_description_column)
      deny bad_key_column.valid?
    end
  end
end
