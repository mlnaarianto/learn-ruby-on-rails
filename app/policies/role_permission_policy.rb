# app/policies/role_permission_policy.rb
# frozen_string_literal: true

class RolePermissionPolicy < ApplicationPolicy
  def edit?   = permitted?(:manage_permissions) && !super_admin_role?
  def update? = edit?

  private

  def resource_name = "roles"

  def super_admin_role?
    record.is_a?(Role) && record.name == User::SUPER_ADMIN_ROLE
  end
end