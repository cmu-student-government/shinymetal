class Whitelist < ActiveRecord::Base
  # Relationships
  
  # Using 'inverse_of: whitelists' here is necessary for nested forms to work properly,
  #   otherwise there is an associations error.
  belongs_to :user_key, inverse_of: :whitelists
  has_many :whitelist_filters, dependent: :destroy
  has_many :filters, through: :whitelist_filters
  
  validates_presence_of :user_key
  
  # Do not allow any whitelist to be empty.
  validate :has_filters
  
  # Scopes
  scope :chronological, -> { order(:created_at) }
  # This scope relies on the fact that each whitelist's filters all have the same resource,
  #   since a whitelist's resource is determined by looking at what filters it has.
  #   A whitelist can only belong to one resource.
  scope :restrict_to, ->(param) { joins(:filters).where("filters.resource = ?", param).distinct }
  
  # Returns the resource that the whitelist belongs to.
  #
  # @return [String] The resource that the whitelist belongs to.
  def resource
    # All filters in a whitelist should have the same resource,
    # and all whitelists have at least one resource.
    return self.filters.first.resource
  end
  
  private
  # Checks that the whitelist has filters.
  #
  # @return [Boolean] True iff the whitelist has at least one filter.
  # @note Adds an error if it returns false.
  def has_filters
    if self.filters.empty?
      errors.add(:base, "A new clause has been created but does not have any filters.")
      return false
    end
    return true
  end
end
