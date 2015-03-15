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
    
    @bender_key_submitted = FactoryGirl.create(:user_key, user:@bender)
    @bender_key_submitted.set_key_as("submitted")

    @bender_key_awaiting_conf = FactoryGirl.create(:user_key, user:@bender)
    @bender_key_awaiting_conf.set_key_as("submitted")
    @bender_key_awaiting_conf.set_key_as("filtered")

    @bender_key_confirmed = FactoryGirl.create(:user_key, user:@bender)
    @bender_key_confirmed.set_key_as("submitted")
    @bender_key_confirmed.set_key_as("filtered")
    @bender_key_confirmed.set_key_as("confirmed")

    @expired_key = FactoryGirl.create(:user_key, user: @bender, time_expired: DateTime.yesterday)
  end
  
  def destroy_user_keys
    @bender_key.destroy
    @bender_key_submitted.destroy
    @bender_key_awaiting_conf.destroy
    @bender_key_confirmed.destroy
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