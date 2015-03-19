FactoryGirl.define do
  
  # factory blueprint for users
  factory :user do
    andrew_id "bender"
  end
  
   # factory blueprint for user keys
  factory :user_key do
    association :user
    status "awaiting_submission"
  end

  #factory blueprint for comments
  factory :comment do
      association :user
      association :user_key
      message "Kiss my shiny metal API"
  end

  factory :filter do
  	resource "organizations"
    filter_name "page"
    filter_value 1
  end

  factory :organization do
      name "cmuTV"
      external_id 1
  end
  
  factory :approval do
    association :user
    association :user_key
  end

end