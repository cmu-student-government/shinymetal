# Test version of the real BridgeapiConnection.
module BridgeapiConnection
  # Dummy method used for unit testing, meant to represent something like a response from CollegiateLink.
  #
  # @param params [HashWithIndifferentAccess] Parameters passed in representing an API request.
  # @return [String, Hash] Dummy data response if the page number was valid, or a blank string if it wasn't.
  def hit_api_endpoint(params)
    page_number = params[:page] || "1"
    # Output successful result
    first_page =
           {"pageNumber" => 1,
            "pageSize" => 2,
            "totalItems" => 4,
            "totalPages" => 2,
            "items" => [{"name" => "First Test Item", "organizationId" => 10},
                        {"name" => "Second Test Item", "organizationId" => 20}]
            }
    second_page =
           {"pageNumber" => 2,
            "pageSize" => 2,
            "totalItems" => 4,
            "totalPages" => 2,
            "items" => [{"name" => "Third Test Item", "organizationId" => 30},
                        {"name" => "Fourth Test Item", "organizationId" => 40}]
            }
    if page_number == "1"
      return first_page
    elsif page_number == "2"
      return second_page
    else #FIXME check what collegiatelink returns
      return ""
    end
  end
end