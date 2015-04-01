class WhitelistFilter < ActiveRecord::Base
  belongs_to :filter
  belongs_to :whitelist

  validates_presence_of :whitelist
  validates_presence_of :filter
end
