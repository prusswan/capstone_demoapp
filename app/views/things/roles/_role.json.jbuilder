json.extract! role, :id, :user_id, :role_name, :mname, :created_at, :updated_at
json.user do
  json.extract! role.user, :id, :name
end
