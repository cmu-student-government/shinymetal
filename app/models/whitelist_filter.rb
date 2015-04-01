class WhitelistFilter < ActiveRecord::Base
  belongs_to :filter
  belongs_to :whitelist

  validates_presence_of :whitelist
  validates_presence_of :filter
  
  validate :whitelist_has_one_resource_only
  
  def whitelist_has_one_resource_only
    # Check that all of a whitelist's filters have the same resource
    return true unless Whitelist.all.to_a.map{|o| o.id}.include?(whitelist_id)
    return true unless Filter.all.to_a.map{|o| o.id}.include?(filter_id)
    incoming_filter = Filter.find(filter_id)
    existing_whitelist_filters = Whitelist.find(whitelist_id).filters
    return true if existing_whitelist_filters.empty?
    unless existing_whitelist_filters.first.resource == incoming_filter.resource
      errors.add(:filter, "has the wrong resource for this whitelist")
      return false
    end
    return true
  end
  
end
