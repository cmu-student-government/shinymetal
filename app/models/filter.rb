# A filter that can be used as a restriction for authorizing API requests.
class Filter < ActiveRecord::Base
  #Relationships
  
  has_many :whitelist_filters
  has_many :whitelists, through: :whitelist_filters
  
  # Validations
  
  validates :resource, inclusion: { in: Resources::RESOURCE_LIST, message: "is not a valid resource" }
  # Use a custom validation for filter names, as determined by resource.
  validate :filter_name_is_valid
  # Filters must be unique.
  validates_uniqueness_of :filter_value, scope: [:resource, :filter_name]
  
  # Scopes
  
  # This scope is used in index and show pages.
  scope :alphabetical, -> { order(:resource).order(:filter_name).order(:filter_value) }
  
  # This scope is used in views, and also for creating whitelists in the user key form.
  scope :restrict_to, ->(param) { where(resource: param) }
  
  # Only allow filter to be destroyed if it is unused.
  before_destroy :is_destroyable?
  
  # Methods
  
  # Print a name for the filter for use in the views.
  #
  # @return [String] A human-readable name for the filter.
  def name
    "\"#{filter_name}\" = \"#{filter_value}\""
  end
  
  # Get all the keys that have whitelists that use this filter.
  #
  # @return [Array<UserKey>] List of distinct user keys that use this filter.
  def user_keys
    self.whitelists.map{|whitelist| whitelist.user_key}.uniq
  end
  
  # Check whether the filter can be destroyed (i.e., has no whitelists).
  #
  # @return [Boolean] True iff the filter has not been used.
  def is_destroyable?
    self.whitelists.empty?
  end
  
  private
  
  # Checks that the filter name is valid by looking up the resource in the hash of
  #   params known to be accepted by the CollegiateLink API as stored statically in Resources.rb,
  #   and checking that the param is there. 
  #
  # @return [Boolean] True iff the filter name is a recognized name for the given resource
  #   or if the resource name was invalid.
  # @note An error is added if it returns false.
  def filter_name_is_valid
    # Return true if the resource name is invalid, to avoid repeating that error.
    return true unless Resources::RESOURCE_LIST.include?(self.resource)
    # Now check that filter_name is a valid parameter for the resource.
    param_list = Resources::PARAM_NAME_HASH[(self.resource.to_sym)]
    if !(param_list.include?(self.filter_name))
      errors.add(:base, "The filter name is not a valid option for the resource selected.")
      return false
    end
    return true
  end
end
