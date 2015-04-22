if Rails.env.test?
  require "./lib/bridgeapi_connection_test_version.rb"
else
  # :nocov:
  require "./lib/bridgeapi_connection.rb"
  # :nocov:
end

# Objectify responses from bridgeapi_connection
class EndpointResponse
  attr_reader :page_number, :page_size, :total_items, :total_pages, :failed
  attr_accessor :items
  
  def initialize(resource, options={})
    if Resources::RESOURCE_LIST.include?(resource)
      hash_response = hit_api_endpoint(resource, options)
      @page_number = hash_response["pageNumber"]
      @page_size = hash_response["pageSize"]
      @total_items = hash_response["totalItems"]
      @total_pages = hash_response["totalPages"]
      @items = hash_response["items"]
      # Set failed to true, just in case we got no response from collegiatelink
      @failed = hash_response.blank?
    else # not a valid resource
      @failed = true
    end
  end

  def set_error_message(message)
    @items = message
  end
  
  def columns
    # This function assumes that each item has the same columns.
    return @items.first.keys
  end
  
  def restrict_to_columns(columns_whitelist)
    for item in @items
      for column in item.keys
	      item.delete(column) unless columns_whitelist.include?(column)
      end
    end
  end
  
  def to_hash
    hash_response = Hash.new
    for label in ["pageNumber", "pageSize", "totalItems", "totalPages","items"]
      hash_response[label] = self.send(label.underscore.to_sym)
    end
    return hash_response
  end
end