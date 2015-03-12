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

end