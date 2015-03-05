class Filter < ActiveRecord::Base
  # Scopes
  scope :alphabetical, -> { order(:filter_name).order(:filter_value) }
  
  # Methods
  def name
    filter_name + ' : ' + filter_value
  end
end
