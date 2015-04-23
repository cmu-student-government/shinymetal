# An organization with an Id in CollegiateLink.
class Organization < ActiveRecord::Base
  # Relationships
  
  has_many :user_key_organizations
  has_many :user_keys, through: :user_key_organizations
  
  # Scopes
  
  scope :alphabetical, -> { order("lower(name)") }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  
  # Methods
  
  # Class method to get the organizations which don't exist in CollegiateLink anymore,
  #   but are still linked to ongoing keys. This method should never be needed to be used,
  #   but is here just in case CollegiateLink changes organization id values for an organization.
  #
  # @return [Array<Organization>] Colleciton of organizations that have ongoing keys but are inactive.
  def self.inactive_but_with_nonexpired_keys
    Organization.inactive.alphabetical.to_a.reject{|o| o.user_keys.not_expired.empty?}
  end
  
  # Class method to repopulate the organizations look-up table, to be done automatically
  #   at some time interval or manually by the website administrator.
  #
  # @return [Boolean] True iff the method call was successful. 
  def self.repopulate
    # First, fetch an array of all organizations still believed to be in CollegiateLink.
    our_active_orgs_hash = Organization.get_our_active_organizations_hash
    # Second, fetch orgs from API
    their_result_list = Organization.get_their_result_list
    # Second-and-a-half, return false if their result list was nil (because there was an error)
    return false if their_result_list.nil?
    
    # Third, create any organizations for new items.
    for item in their_result_list
      if our_active_orgs_hash[item] # This one exists in our database already.
        our_active_orgs_hash.delete(item)
      else # We don't have this one yet.
        Organization.create(external_id: item[0], name: item[1])
      end
    end
    
    # Fourth, inactivate any of our objects that remain in our hash.
    for object in our_active_orgs_hash.values
      object.update_attribute(:active, false)
      object.update_attribute(:name, object.name.strip + " (removed from CollegiateLink)")
    end
    
    return true # We were successful.
  end
  
  private
  # Class method to get hash of active organizations in this system.
  #
  # @return [Hash] Each key is of format [Integer,String], where the integer is the external id
  #   and the string is the org name. Key's value is the Organization object.
  def self.get_our_active_organizations_hash
    our_active_orgs_hash = {}
    Organization.active.to_a.each {|o| our_active_orgs_hash[[o.external_id, o.name]] = o }
    # our_active_orgs_hash = { [1234,"name"] => object, [2134,"other_name"] => object,... }
    return our_active_orgs_hash
  end
  
  # Class method to get the complete list of organizationIds in CollegiateLink.
  #
  # @return [Array<Array>, nil] Nil if there was a failure to get data form CollegiateLink,
  #   or a list of [Integer, String], corresponding to the organizationId and name of the Org.
  def self.get_their_result_list
    result_list = []
    page_number = 1
    total_pages = nil
    while total_pages.nil? or page_number <= total_pages
      page_response = EndpointResponse.new(nil, {endpoint: "organizations", page: page_number.to_s})
      # If there was an error, return nil immediately.
      return nil if page_response.failed
      # Otherwise, add the organizations on this page to our list of all their orgs.
      total_pages = page_response.total_pages
      for item in page_response.items
        result_list.append([item["organizationId"],item["name"]])
      end
      page_number = page_number + 1
    end
    # Example: result_list = [ [1234,"name"], [2134,"other_name"],...]
    return result_list
  end
end
