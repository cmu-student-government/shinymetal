# Connection between filter and whitelist.
#  By existing, it shows that the filter is part of the whitelist.
class WhitelistFilter < ActiveRecord::Base
  # Relationships
  
  belongs_to :filter
  belongs_to :whitelist

  # Validations

  validates_presence_of :whitelist
  validates_presence_of :filter
  validates_uniqueness_of :whitelist_id, scope: :filter_id
end
