# app/controllers/role_permissions_controller.rb
class RolePermissionsController < ApplicationController
  include AuthorizesWithPundit

  before_action :set_role

  # GET /roles/:role_id/permissions/edit
  def edit
    authorize @role, :manage_permissions?
    load_permissions
  end

  # PATCH /roles/:role_id/permissions
  def update
    authorize @role, :manage_permissions?

    ids = Array(params.dig(:role, :permission_ids)).compact_blank
    # whitelist: hanya id permission yang benar-benar ada
    @role.permission_ids = Permission.where(id: ids).pluck(:id)

    redirect_to roles_path, notice: "Permission role #{@role.name} diperbarui."
  end

  private

  def set_role
    @role = policy_scope(Role).find(params[:role_id])
  end

  def load_permissions
    @permissions_by_group = Permission.order(:group, :name).group_by(&:group)
    @selected_ids = @role.permission_ids.to_set
  end
end
