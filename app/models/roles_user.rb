# The table that links roles with users (generally named RoleUser.rb)
class RolesUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  
  set_primary_keys :user_id, :role_id
end
