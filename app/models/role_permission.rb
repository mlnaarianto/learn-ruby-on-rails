# app/models/role_permission.rb
class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission
end