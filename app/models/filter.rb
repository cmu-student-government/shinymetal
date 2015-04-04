class Filter < ActiveRecord::Base
  #Relationships
  has_many :whitelist_filters, autosave: true
  has_many :whitelists, through: :whitelist_filters
  
  # Validations
  validates :resource, inclusion: { in: Resource::RESOURCE_LIST, message: "is not a valid resource" }
  # Custom validation for filter names as determined by resource
  validate :filter_name_is_valid
  
  # Scopes
  scope :alphabetical, -> { order(:resource).order(:filter_name).order(:filter_value) }
  scope :restrict_to, ->(param) { where(resource: param) }
  
  before_destroy :is_destroyable?
  
  # Methods  
  def name
    "\"#{filter_name}\" = \"#{filter_value}\""
  end
  
  def is_destroyable?
    self.whitelists.empty?
  end
  
  def user_keys
    self.whitelists.map{|whitelist| whitelist.user_key}.uniq
  end
  
  def filter_name_is_valid
    filter_param_list = Resource::RESOURCE_LIST
    return true unless filter_param_list.include?(self.resource)
    param_list = Resource::PARAM_NAME_HASH[(self.resource.to_sym)]
    if !(param_list.include?(self.filter_name))
      errors.add(:filter_name, "is not a valid filter name for that resource")
      return false
    end
    return true
  end
end
