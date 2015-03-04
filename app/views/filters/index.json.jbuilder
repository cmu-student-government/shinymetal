json.array!(@filters) do |filter|
  json.extract! filter, :id, :resource, :filter_name, :filter_value
  json.url filter_url(filter, format: :json)
end
