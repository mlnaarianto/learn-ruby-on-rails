# app/policies/role_permission_policy.rb
# frozen_string_literal: true

class RolePermissionPolicy < ApplicationPolicy
  def create?  = permitted?(:update)
  def destroy? = permitted?(:update)

  private

  def resource_name = "roles"
end
