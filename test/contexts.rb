module Contexts
  # Users
  def create_users
    @bender = FactoryGirl.create(:user)
    @fry = FactoryGirl.create(:user, andrew_id: 'fry', role: 'admin', is_approver: true)
    @leela = FactoryGirl.create(:user, andrew_id: 'leela', role: 'admin', is_approver: true)
    @zoidberg = FactoryGirl.create(:user, andrew_id: 'zoidberg')
  end
  
  def destroy_users
    @bender.destroy
    @fry.destroy
    @leela.destroy
    @zoidberg.destroy
  end
  
  # User keys
  def create_user_keys
    @bender_key = FactoryGirl.create(:user_key, user: @bender)
    
    @bender_key_submitted = FactoryGirl.create(:user_key, user: @bender)
    @bender_key_submitted.set_key_as("submitted")

    @bender_key_awaiting_conf = FactoryGirl.create(:user_key, user: @bender)
    @bender_key_awaiting_conf.set_key_as("submitted")
    @bender_key_awaiting_conf.set_key_as("filtered")

    @bender_key_confirmed = FactoryGirl.create(:user_key, user: @bender)
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
  
  #Comments
  def create_comments
    @angrycomment = FactoryGirl.create(:comment, user: @bender, user_key: @bender_key)
    @happycomment = FactoryGirl.create(:comment, user: @bender, user_key: @bender_key, message: "I love APIs so much")
    @happycomment.time_posted = 10.minutes.ago
  end

  def destroy_comments
    @angrycomment.destroy
    @happycomment.destroy
  end

  #Filters
  def create_filters
    @organizations_page_filter = FactoryGirl.create(:filter)
    @organizations_page_filter2 = FactoryGirl.create(:filter, filter_value: '2')
    @organizations_status_filter = FactoryGirl.create(:filter, filter_name: 'status', filter_value: 'inactive' )
  end

  def destroy_filters
    @organizations_page_filter.destroy
    @organizations_page_filter2.destroy
    @organizations_status_filter.destroy
  end

  #Organizations
  def create_organizations
    @cmutv = FactoryGirl.create(:organization)
    @wrct = FactoryGirl.create(:organization, name: "WRCT", external_id: 2)
    @abfilms = FactoryGirl.create(:organization, name: "AB Films", external_id: 3)
  end

  def destroy_organizations
    @cmutv.destroy
  end

  # Create everything at once with one method call
  def create_everything
    create_users
    create_user_keys
    create_comments
    create_filters
    create_organizations
  end
  
  # Destroy everything at once
  def destroy_everything
    destroy_user_keys
    destroy_users
    destroy_comments
    destroy_filters
    destroy_organizations
  end
end