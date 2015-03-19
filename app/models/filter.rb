class Filter < ActiveRecord::Base
  #Relationships
  has_many :user_key_filters
  
  # Scopes
  scope :alphabetical, -> { order(:filter_name).order(:filter_value) }
  
  # Methods
  def name
    filter_name + ' : ' + filter_value
  end
end
