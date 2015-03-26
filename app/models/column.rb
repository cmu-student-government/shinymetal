class Column < ActiveRecord::Base
  #Relationships
  has_many :user_key_columns
  has_many :user_keys, through: :user_key_columns
  
  # Validations
  validates :resource, inclusion: { in: Resource::RESOURCE_LIST, message: "is not a valid resource" }
  # Custom validation for column names as determined by resource
  validate :column_name_is_valid
  
  # Scopes
  scope :alphabetical, -> { order(:column_name) }
  
  # Methods
  def name
    column_name + ' : ' + column_value
  end
  
  def column_name_is_valid
    column_param_list = Resource::RESOURCE_LIST
    return true unless column_param_list.include?(self.resource)
    param_list = Resource::COLUMN_NAME_HASH[(self.resource.to_sym)]
    if !(param_list.include?(self.column_name))
      errors.add(:column_name, "is not a valid column name for that resource")
      return false
    end
    return true
  end
end
