json.array!(@user_keys) do |user_key|
  json.extract! user_key, :id, :status, :date_requested, :expiration_date, :value, :application_text
  json.url user_key_url(user_key, format: :json)
end
