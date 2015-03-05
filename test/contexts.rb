module Contexts
  # Users
  def create_users
    @bender = FactoryGirl.create(:user)
  end
  
  def destroy_users
    @bender.destroy
  end
  
  # User keys
  def create_user_keys
    @bender_key = FactoryGirl.create(:user_key, user: @bender) 
  end
  
  def destroy_user_keys
    @bender_key.destroy
  end
  
  # Create everything at once with one method call
  def create_everything
    create_users
    create_user_keys
  end
  
  # Destroy everything at once
  def destroy_everything
    destroy_user_keys
    destroy_users
  end
end