# For the sake of testing, use a static test JSON response.
if Rails.env.test?
  require "./lib/bridgeapi_connection_test_version.rb"
else
  # :nocov:
  require "./lib/bridgeapi_connection.rb"
  # :nocov:
end

# Objectify responses from bridgeapi_connection to handle the logic for the API controller.
class EndpointResponse
  # Gets access to the hit_api_endpoint method.
  include BridgeapiConnection
  
  # Some of these readers are used in other models, i.e. the repopulate methods.
  # @return [Integer] The page number.
  attr_reader :page_number
  # @return [Integer] The page size.
  attr_reader :page_size
  # @return [Integer] The total items on the page.
  attr_reader :total_items
  # @return [Integer] The total number of pages that the response was condensed into.
  attr_reader :total_pages
  # @return [Array<Hash>] The response items, such that each item is a hash in the list.
  attr_reader :items

  # This reader is used in the API controller and in model methods to check if the response failed.
  # @return [String, nil] Error message if the response failed.
  attr_reader :failed

  # Initialize an EndpointResponse to contain logic of handling an answer from CollegiateLink.
  #
  # @param user_key [UserKey, nil] The key of the requesting user, or nil if used by a repopulate method.
  # @param params [HashWithIndifferentAccess] Parameters passed into the URL, or repopulate method.
  # @return [EndpointResponse] The returned response contains a hash to be returned in the API controller.
  def initialize(user_key, params)
    @resource = params[:endpoint]
    if Resources::RESOURCE_LIST.include?(@resource)
      hash_response = BridgeapiConnection::hit_api_endpoint(params)
      @user_key = user_key
      @page_number = hash_response["pageNumber"]
      @page_size = hash_response["pageSize"]
      @total_items = hash_response["totalItems"]
      @total_pages = hash_response["totalPages"]
      @items = hash_response["items"]
      # Set failed to true in case we got no response from collegiatelink
      @failed = "error, there was no response from CollegiateLink" if hash_response.blank?
      # Restrict the columns in the response according to the passed-in user_key
      unless (@user_key.nil? or @failed)
        restrict_columns
        # Set failed if there are no columns left
        @failed = "error, no columns permitted for this resource" if self.columns.empty?
      end
    else # not a valid resource
      @failed = "error, the requested resource does not exist"
    end
  end

  # Get the columns that is an endpoint response has whitelisted on its items.
  #
  # @return [Array<String>] The columns that are used as keys in the first item.
  def columns
    # This function assumes that each item has the same columns.
    return @items.first.keys
  end

  # Convert the response to a hash to be returned as a JSON response in the controller.
  #
  # @return [Hash] A hash that mirrors the format of what CollegiateLink returns.
  def to_hash
    hash_response = Hash.new
    for label in ["pageNumber", "pageSize", "totalItems", "totalPages","items"]
      hash_response[label] = self.send(label.underscore.to_sym)
    end
    return hash_response
  end

  private
  # Restrict the response based on the columns permitted for the user_key.
  def restrict_columns
    columns_whitelist = @user_key.columns.restrict_to(@resource).to_a.map{|c| c.name}
    for item in @items
      for column in item.keys
	      item.delete(column) unless columns_whitelist.include?(column)
      end
    end
  end
end
