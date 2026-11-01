# app/policies/user_policy.rb
# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?  = super && can_touch_target?
  def destroy? = super && !self_record? && can_touch_target?

  # Mengubah role seorang user = izin update user
  def assign_roles? = update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      relation = super
      return relation if user.nil? || user.super_admin?

      # Non super admin tidak melihat akun super admin
      relation.where.not(id: UserRole.joins(:role)
                                     .where(roles: { name: User::SUPER_ADMIN_ROLE })
                                     .select(:user_id))
    end
  end

  private

  def self_record?
    record == user
  end

  # Hanya super admin yang boleh menyentuh akun super admin
  def can_touch_target?
    return true if user.super_admin?

    !(record.is_a?(User) && record.super_admin?)
  end
end
