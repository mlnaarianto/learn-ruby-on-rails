# app/policies/role_policy.rb
# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  UNDELETABLE = [ User::SUPER_ADMIN_ROLE, "member" ].freeze   # member dipakai assign_default_role

  def update?  = super && !super_admin_role?
  def destroy? = super && !UNDELETABLE.include?(role_name)

  # Mengatur permission milik role (checkbox di form role) = izin update role
  def manage_permissions? = update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      relation = super
      return relation if user.nil? || user.super_admin?

      # Role super_admin tidak muncul di daftar/dropdown untuk non-super-admin
      relation.where.not(name: User::SUPER_ADMIN_ROLE)
    end
  end

  private

  def role_name
    record.is_a?(Role) ? record.name : nil
  end

  def super_admin_role?
    role_name == User::SUPER_ADMIN_ROLE
  end
end
