# app/controllers/roles_controller.rb
class RolesController < ApplicationController
  include AuthorizesWithPundit

  before_action :set_role, only: %i[edit update destroy]

  def index
    authorize Role
    @roles = policy_scope(Role).includes(:permissions).order(:name)
    @user_counts = UserRole.group(:role_id).count   # hindari N+1 untuk kolom "jumlah user"
  end

  def new
    @role = Role.new
    authorize @role
  end

  def create
    @role = Role.new(role_params(:create))
    authorize @role

    if @role.save
      redirect_to edit_role_permissions_path(@role),
                  notice: "Role dibuat. Sekarang atur permission-nya."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @role
  end

  def update
    authorize @role

    if @role.update(role_params(:update))
      redirect_to roles_path, notice: "Role #{@role.name} diperbarui."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @role

    if @role.users.exists?
      redirect_to roles_path, alert: "Role masih dipakai #{@role.users.count} user."
    else
      @role.destroy!
      redirect_to roles_path, notice: "Role #{@role.name} dihapus."
    end
  end

  private

  def set_role
    @role = policy_scope(Role).find(params[:id])
  end

  # Nama role dikunci setelah dibuat, karena kode merujuk nama ("member", "super_admin")
  def role_params(action)
    allowed = action == :create ? %i[name description] : %i[description]
    params.require(:role).permit(*allowed)
  end
end