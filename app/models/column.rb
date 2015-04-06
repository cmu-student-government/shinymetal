require "./lib/bridgeapi_connection.rb"

class Column < ActiveRecord::Base
  #Relationships
  has_many :user_key_columns
  has_many :user_keys, through: :user_key_columns
  
  # Validations
  validates :resource, inclusion: { in: Resource::RESOURCE_LIST, message: "is not a valid resource" }
  validates_uniqueness_of :resource, scope: :column_name
  # Custom validation for column names as determined by resource
  
  # Scopes
  scope :alphabetical, -> { order(:column_name) }
  scope :restrict_to, ->(param) { where(resource: param) }
  
  # Methods
  def name
    column_name
  end
  
  # Load columns directly from CollegiateLink
  # FIXME needs error handling in case there is no response
  def self.repopulate
    # Note that this will hit all resources, and add Columns for any column
    # that has a non-blank instance in CollegiateLink.
    for resource in Resource::RESOURCE_LIST
      # Get the JSON response
      response = hit_api_endpoint(resource)
      # Select out the blank columns for each item, map each item to its keys only,
      # flatten the outer list, and keep the unique result.
      result_list = response["items"].map{|result| result.select{ |k, v| !v.blank? }.keys }.flatten.uniq
      # Create a Column for each if it doesn't exist already
      for result_name in result_list
        params = { resource: resource, column_name: result_name }
        if Column.where(params).empty?
          Column.create(params)
        end
      end
    end
    return true
  end
end
