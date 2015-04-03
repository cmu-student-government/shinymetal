require "./lib/bridgeapi_connection.rb"

class Organization < ActiveRecord::Base
  # Relationships
  has_many :user_key_organizations
  has_many :user_keys, through: :user_key_organizations
  
  # Scopes
  scope :alphabetical, -> { order("lower(name)") }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  
  # Methods
  # Repopulate the organizations look-up table
  # FIXME 1. needs error handling for bad jSON response, 2. only looks at 1 page of orgs on the site
  def self.repopulate
    # First, fetch an array of all organizations still believed to be in CollegiateLink.
    our_active_orgs_hash = get_our_active_organizations_hash
    # Second, fetch orgs from API
    their_result_list = get_their_result_list
    
    # Third, create any organizations for new items.
    for item in their_result_list
      if our_active_orgs_hash[item] # This one exists in our database already.
        our_active_orgs_hash.delete(item)
      else # We don't have this one yet.
        Organization.create(external_id: item[0], name: item[1])
      end
    end
    
    # Fourth, inactivate any of our objects that remain in our hash.
    for object in our_objects_without_matches.values
      object.update_attribute(:active, false)
      object.update_attribute(:name, object.name.strip + " (removed from CollegiateLink)")
    end
    
    return true
  end
  
  private
  def get_our_active_organizations_hash
    our_active_orgs_hash = {}
    Organization.active.to_a.each {|o| our_active_orgs_hash[[o.external_id, o.name]] = o }
    # our_active_orgs_hash = { [1234,"name"] => object, [2134,"other_name"] => object,... }
    return active_orgs_hash
  end
  
  def get_their_result_list
    body = hit_api_endpoint("organizations")
    result_list = []
    for item in body["items"]
      result_list.append([item["organizationId"],item["name"]])
    end
    # result_list = [ [1234,"name"], [2134,"other_name"],...]
    return result_list
  end
end
