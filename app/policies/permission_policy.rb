# app/policies/permission_policy.rb
# frozen_string_literal: true

class PermissionPolicy < ApplicationPolicy
  def create?  = false
  def update?  = false
  def destroy? = false
end