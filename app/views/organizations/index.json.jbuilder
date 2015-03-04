json.array!(@organizations) do |organization|
  json.extract! organization, :id, :name, :external_id
  json.url organization_url(organization, format: :json)
end
