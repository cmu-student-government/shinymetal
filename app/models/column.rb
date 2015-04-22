class Column < ActiveRecord::Base
  #Relationships
  has_many :user_key_columns
  has_many :user_keys, through: :user_key_columns
  
  # Validations
  validates :resource, inclusion: { in: Resources::RESOURCE_LIST, message: "is not a valid resource" }
  validates_uniqueness_of :resource, scope: :column_name
  # Custom validation for column names as determined by resource
  
  # Scopes
  scope :alphabetical, -> { order(:resource).order(:column_name) }
  scope :restrict_to, ->(param) { where(resource: param) }
  
  # Methods
  def name
    column_name
  end
  
  # Load columns directly from CollegiateLink
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