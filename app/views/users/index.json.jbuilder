json.array!(@users) do |user|
  json.extract! user, :id, :andrew_id, :role, :is_approver
  json.url user_url(user, format: :json)
end
