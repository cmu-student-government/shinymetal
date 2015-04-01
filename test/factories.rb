FactoryGirl.define do
  
  # factory blueprint for users
  factory :user do
    andrew_id "bender"
    role "requester"
    active true
  end
  
   # factory blueprint for user keys
  factory :user_key do
    association :user
    agree true
    name "Bender Key"
    proposal_text_one "Test"
    proposal_text_two "Test"
    proposal_text_three "Test"
    proposal_text_four "Test"
    proposal_text_five "Test"
    proposal_text_six "Test"
    proposal_text_seven "Test"
    # Eight is optional
    proposal_text_eight nil
    status "awaiting_submission"
  end

  #factory blueprint for comments
  factory :comment do
    association :comment_user #user, renamed to approval_user for clarity
    association :user_key
    message "Kiss my shiny metal API"
  end

  factory :filter do
    resource "organizations"
    filter_name "status"
    filter_value "active"
  end
  
  factory :column do
    resource "organizations"
    column_name "description"
  end

  factory :organization do
    name "cmuTV"
    external_id 1
  end
  
  # factory blueprint for user key organizations
  factory :user_key_organization do
    association :organization
    association :user_key
  end

  # factory blueprint for whitelist filter
  factory :whitelist_filter do
    association :filter
    association :whitelist
  end
  
  # factory blueprint for whitelist
  factory :whitelist do
    association :user_key
  end
  
  # factory blueprint for user key column
  factory :user_key_column do
    association :column
    association :user_key
  end
  
  factory :approval do
    association :approval_user #user, renamed to approval_user for clarity
    association :user_key
  end

end