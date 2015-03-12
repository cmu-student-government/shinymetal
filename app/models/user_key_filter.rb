class UserKeyFilter < ActiveRecord::Base
  belongs_to :filter
  belongs_to :user_key

  validates :filter_id, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :user_key_id, presence: true, numericality: { greater_than: 0, only_integer: true }

end
