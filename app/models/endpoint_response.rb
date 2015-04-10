require "./lib/bridgeapi_connection.rb"

# Objectify responses from bridgeapi_connection
class EndpointResponse
  attr_reader :page_number, :page_size, :total_items, :total_pages, :items, :failed
  
  def initialize(resource, options={})
    hash_response = hit_api_endpoint(resource, options)
    # If there was an error, the rest will be nil anyway.
    @page_number = hash_response["pageNumber"]
    @page_size = hash_response["pageSize"]
    @total_items = hash_response["pageSize"]
    @total_pages = hash_response["totalPages"]
    @items = hash_response["items"]
    @failed = hash_response.blank?
  end
  
  def columns
    # This function assumes that each item has the same columns.
    @items.first.keys
  end
  
  def restrict_to_columns(columns_whitelist)
    for item in @items
      for col in item
	item.delete(col) unless columns_whitelist.include?(col)
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