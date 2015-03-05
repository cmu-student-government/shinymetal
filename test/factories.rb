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

end