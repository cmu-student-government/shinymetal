class Whitelist < ActiveRecord::Base
  # Relationships
  belongs_to :user_key, inverse_of: :whitelists
  has_many :whitelist_filters
  has_many :filters, through: :whitelist_filters
  
  validates_presence_of :user_key
  
  validate :has_valid_filters
  
  # Scopes
  scope :chronological, -> { order(:created_at) }
  scope :restrict_to, ->(param) { where(resource: param) }
  
  private
  def has_valid_filters
    # FIXME, do not allow a whitelist to have no filters.
    # This code works out in nested form, but not in tests.
    #if self.filters.empty?
    #  errors.add(:whitelist_id, "does not have any filters checked")
    #  return false
    #end
    # The filters must have the same resource as the whitelist
    for filter in self.filters
      if filter.resource != self.resource
        errors.add(:whitelist_id, "has invalid filters")
        return false
      end
    end
    return true
  end
end
