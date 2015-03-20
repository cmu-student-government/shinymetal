json.users @users, partial: 'api/v1/users/show', as: :user

json.total_count @users.respond_to?(:total_entries) ? 
@users.total_entries : @users.to_a.count