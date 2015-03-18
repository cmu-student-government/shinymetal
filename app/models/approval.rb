class Approval < ActiveRecord::Base
  belongs_to :approval_user, class_name: User, foreign_key: :user_id
  belongs_to :user_key
end
