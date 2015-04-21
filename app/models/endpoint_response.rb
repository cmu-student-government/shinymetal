if Rails.env.test?
  require "./lib/bridgeapi_connection_test_version.rb"
else
  # :nocov:
  require "./lib/bridgeapi_connection.rb"
  # :nocov:
end

# Objectify responses from bridgeapi_connection
class EndpointResponse
  attr_reader :page_number, :page_size, :total_items, :total_pages, :items, :failed
  
  # Initialize an EndpointResponse to contain logic of handling an answer from CollegiateLink.
  #
  # @param user_key [UserKey, nil] The key of the requesting user, or nil if used by a repopulate method.
  # @param params [Hash] Parameters passed into the URL, or repopulate method.
  def initialize(user_key, params)
    @resource = params[:endpoint]
    if Resources::RESOURCE_LIST.include?(@resource)
      hash_response = hit_api_endpoint(params)
      @user_key = user_key
      @page_number = hash_response["pageNumber"]
      @page_size = hash_response["pageSize"]
      @total_items = hash_response["totalItems"]
      @total_pages = hash_response["totalPages"]
      @items = hash_response["items"]
      # Set failed to true in case we got no response from collegiatelink
      @failed = hash_response.blank?
      # Restrict the columns in the response according to the passed-in user_key
      restrict_columns unless (@failed or @user_key.nil?)
    else # not a valid resource
      @failed = true
    end
  end
  
  def columns
    # This function assumes that each item has the same columns.
    return @items.first.keys
  end
  
  def to_hash
    hash_response = Hash.new
    for label in ["pageNumber", "pageSize", "totalItems", "totalPages","items"]
      hash_response[label] = self.send(label.underscore.to_sym)
    end
    return hash_response
  end
  
  private 
  def restrict_columns
    columns_whitelist = @user_key.columns.restrict_to(@resource).to_a.map{|c| c.name}
    for item in @items
      for column in item.keys
	      item.delete(column) unless columns_whitelist.include?(column)
      end
    end
  end
end