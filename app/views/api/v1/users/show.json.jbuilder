user ||= @user

json.id user['id']
json.andrew_id user['andrew_id']
json.is_approver user['is_approver']
json.created_at user['created_at']
json.updated_at user['updated_at']
