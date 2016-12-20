# Objectify requests to the API as made in the Api Controller.
class EndpointRequest
  # @return [String, nil] The error message for any endpoint request that was not allowed.
  attr_reader :failed

  # Initialize an EndpontRequest.
  #
  # @param user_key [UserKey] User key with the Gen API Key that matches the one passed in earlier.
  # @param params [HashWithIndifferentAccess] The request endpoint and options that the user passed in,
  #   not including the endpoint itself. For example, { "page" => "1", "status" => "active" }.
  # @return [EndpointRequest]
  def initialize(user_key, params)
    @user_key = user_key
    @params = params
    # It doesn't matter here if the resource passed in exists or not; that will cause errors in the response.
    @resource = params[:endpoint]
    @failed = "error, the request's combination of parameters is not allowed for this API key" unless self.valid?
  end

  # Determines if the given user key is allowed to request the paramaters passed in.
  # Only the restrictions of one whitelist needs to be included for the request to be allowed.
  #
  # @return [Boolean] True, iff the given options are allowed for this user_key.
  def valid?
    filter_group_list = @user_key.whitelists.restrict_to(@resource).to_a.map{|w| w.filters.to_a}
    # If the key has no whitelists at all, the key has no access through normal filters.
    # (If the key has no columns, the key has no access at all, but we check for that in EndpointResponse.)
    # Map the filters for each individual whitelist into a list to be checked.
    return true if filter_group_list.any? { |fg| matches_options? fg }

    # No filters were matched, so check for organizations instead.
    return has_valid_organization_id?
  end

  # Determines if the paramaters passed contain the values of a given list of filters.
  #
  # @param filter_group [Array<Filter>] List of filter objects, already mapped earlier from one of the whitelists.
  # @return [Boolean] Whether or not the given filter group contains this list of filters.
  private
  # def matches_options?(filter_group)
  #   for filter in filter_group
  #     # Downcase the values, because CollegiateLink is case insensitive.
  #     # We could theoretically downcase all keys and values from the beginning; this would require changing outcomes in unit tests.
  #     requested_filter_value = @params[filter.filter_name.to_sym]
  #     # Accepts anything for this filter, let it pass
  #     next if filter.filter_value == "*"
  #     return false if
  #       requested_filter_value.nil? ||
  #       requested_filter_value.downcase != filter.filter_value.downcase
  #   end
  #   return true
  # end

  def matches_options?(filter_group)
    return filter_group.all? do |filter|
      next true if filter.filter_value == "*" # Accepts anything for this filter, let it pass

      # Get the requests value for this filter
      # If it's not set then it will obviously not match any of our accepted values
      requested_val = CGI::unescape(@params[filter.filter_name.to_sym])
      return false if requested_val.nil?

      # Build an array out of any comma-separated accepted filter values
      accepted_vals = filter.filter_value.split(",")

      # Do any of the accepted values for this filter match (case-insensitive)?
      next accepted_vals.any? { |val| val.strip.casecmp(requested_val) == 0 }
    end
  end

  # Check if the user key's request is valid through its organization id, whether it has one or not.
  #
  # @return [Boolean] True if the request had an org Id that is associated with the request's key.
  def has_valid_organization_id?
    return @user_key.organizations.active.map{|o| o.external_id.to_s}.include?(@params[:organizationId].to_s)
  end
end
