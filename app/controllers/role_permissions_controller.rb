# app/controllers/role_permissions_controller.rb
class RolePermissionsController < ApplicationController
  include AuthorizesWithPundit

  before_action :set_role

  # GET /roles/:role_id/permissions/edit
  def edit
    authorize @role, :edit?, policy_class: RolePermissionPolicy
    load_permissions
  end

  # PATCH /roles/:role_id/permissions
  def update
    authorize @role, :update?, policy_class: RolePermissionPolicy

    requested_ids = Array(params.dig(:role, :permission_ids)).compact_blank.map(&:to_i)
    grantable_ids = grantable_permissions.pluck(:id)

    # 1. hanya permission yang boleh diberikan user ini (sekaligus whitelist id valid)
    allowed_ids = requested_ids & grantable_ids

    # 2. permission lama di luar jangkauan user tetap dipertahankan, tidak ikut tercabut
    kept_ids = @role.permission_ids - grantable_ids

    @role.permission_ids = (allowed_ids + kept_ids).uniq

    redirect_to roles_path, notice: "Permission role #{@role.name} diperbarui."
  end

  private

  def set_role
    @role = policy_scope(Role).find(params[:role_id])
  end

  def load_permissions
    @permissions_by_group = Permission.order(:group, :name).group_by(&:group)
    @selected_ids  = @role.permission_ids.to_set
    @grantable_ids = grantable_permissions.pluck(:id).to_set
  end

  # Super admin boleh memberi semua; selain itu hanya yang ia miliki sendiri
  def grantable_permissions
    current_user.super_admin? ? Permission.all : current_user.permissions
  end
end