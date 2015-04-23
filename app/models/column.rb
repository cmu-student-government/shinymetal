# A column, which is a component of an item's hash of columns and values,
#   as part of the list of item hashes that make up a particular resource's
#   response from CollegiateLink.
class Column < ActiveRecord::Base
  #Relationships
  
  has_many :user_key_columns
  has_many :user_keys, through: :user_key_columns
  
  # Validations
  
  validates :resource, inclusion: { in: Resources::RESOURCE_LIST, message: "is not a valid resource" }
  # This validation should never be hit, but is a safeguard for the repopulate method.
  validates_uniqueness_of :resource, scope: :column_name
  
  # Scopes
  
  scope :alphabetical, -> { order(:resource).order(:column_name) }
  scope :restrict_to, ->(param) { where(resource: param) }
  
  # Methods
  
  # Get the name of the column. This function would not be necessary if the column name attribute
  #   was changed to just be name; the only reason for this function is that
  #   calling the attribute 'column name' made it easier to differentiate in the
  #   design phase of development, but 'name' is practically better.
  #
  # @return [String] The name of the column.
  def name
    column_name
  end
  
  # Load columns directly from CollegiateLink into the database, done automatically by cronjob
  #   or manually by admin.
  #
  # @return [Boolean] True iff the request to CollegiateLink was successful.
  def self.repopulate
    # Note that this will hit all resources and get the columns from the first item.
    for resource in Resources::RESOURCE_LIST
      # First, get one response for this resource, not tied to any user key
      endpoint_response = EndpointResponse.new(nil, endpoint: resource)
      # Return false if it failed
      return false if endpoint_response.failed
      # Otherwise, create a Column for each if it doesn't exist already
      for result_name in endpoint_response.columns
        params = { resource: resource, column_name: result_name }
        Column.create(params) if Column.where(params).empty?
      end
    end
    return true
  end
end