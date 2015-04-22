class Whitelist < ActiveRecord::Base
  # Relationships
  belongs_to :user_key, inverse_of: :whitelists
  has_many :whitelist_filters, dependent: :destroy
  has_many :filters, through: :whitelist_filters
  
  validates_presence_of :user_key
  
  validate :has_filters
  
  # Scopes
  scope :chronological, -> { order(:created_at) }
  # This scope ignores the fact that each whitelist's filters all have the same resource; thus it may be inefficient.
  scope :restrict_to, ->(param) { joins(:filters).where("filters.resource = ?", param).distinct }
  
  def resource
    # All filters in a whitelist should have the same resource.
    return self.filters.first.resource
  end
  
  private
  # Do not allow a whitelist to have no filters.
  def has_filters
    if self.filters.empty?
      errors.add(:base, "A new clause has been created but does not have any filters.")
      return false
    end
    return true
  end
end
