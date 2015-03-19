module Contexts
  # Users
  def create_users
    @bender = FactoryGirl.create(:user)
    @fry = FactoryGirl.create(:user, andrew_id: 'fry', role: 'admin')
    @leela = FactoryGirl.create(:user, andrew_id: 'leela', role: 'staff_approver')
    @zoidberg = FactoryGirl.create(:user, andrew_id: 'zoidberg', role: 'staff_not_approver')
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
    @bender_key_submitted.set_status_as :awaiting_filters

    @bender_key_awaiting_conf = FactoryGirl.create(:user_key, user: @bender)
    @bender_key_awaiting_conf.set_status_as :awaiting_filters
    @bender_key_awaiting_conf.set_status_as :awaiting_confirmation
    # Changing time_submitted to test for chronological scopes
    @bender_key_awaiting_conf.time_submitted = 2.days.ago
    @bender_key_awaiting_conf.save!
    
    @bender_key_awaiting_conf_approved = FactoryGirl.create(:user_key, user: @bender, time_submitted: 4.days.ago)
    @bender_key_awaiting_conf_approved.set_status_as :awaiting_filters
    @bender_key_awaiting_conf_approved.set_status_as :awaiting_confirmation
    # Changing time_submitted to test for chronological scopes
    @bender_key_awaiting_conf_approved.time_submitted = 4.days.ago
    @bender_key_awaiting_conf_approved.save!

    @bender_key_confirmed = FactoryGirl.create(:user_key, user: @bender)
    @bender_key_confirmed.set_status_as :awaiting_filters
    @bender_key_confirmed.set_status_as :awaiting_confirmation
    # Key cannot be marked as confirmed until it is given approvals;
    # Thus, key is set to confirmed when approvals are created below.
    # Changing time_submitted to test for chronological scopes
    @bender_key_confirmed.time_submitted = 6.days.ago
    @bender_key_confirmed.save!

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
    @angrycomment = FactoryGirl.create(:comment, comment_user: @bender, user_key: @bender_key)
    @happycomment = FactoryGirl.create(:comment, comment_user: @bender, user_key: @bender_key, message: "I love APIs so much")
    @happycomment.created_at = 10.minutes.ago
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
  
  # Approvals
  def create_approvals # Every approver in testing suite must approve bender's approved key
    @leela_approval_for_confirmed = FactoryGirl.create(:approval, approval_user: @leela, user_key: @bender_key_confirmed)
    @fry_approval_for_confirmed = FactoryGirl.create(:approval, approval_user: @fry, user_key: @bender_key_confirmed)
    @leela_approval_for_awaiting = FactoryGirl.create(:approval, approval_user: @leela, user_key: @bender_key_awaiting_conf_approved)
    @fry_approval_for_awaiting = FactoryGirl.create(:approval, approval_user: @fry, user_key: @bender_key_awaiting_conf_approved)
    
    # Now that approvals exist, we can confirm the key
    @bender_key_confirmed.set_status_as :confirmed
  end
  
  def destroy_approvals
    @leela_approval_for_confirmed.destroy
    @fry_approval_for_confirmed.destroy
    @leela_approval_for_awaiting.destroy
    @fry_approval_for_awaiting.destroy
  end

  # Create everything at once with one method call
  def create_everything
    create_users
    create_user_keys
    create_comments
    create_filters
    create_organizations
    create_approvals
  end
  
  # Destroy everything at once
  def destroy_everything
    destroy_approvals
    destroy_user_keys
    destroy_users
    destroy_comments
    destroy_filters
    destroy_organizations
  end
end