# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include AuthorizesWithPundit

  before_action :set_user, only: %i[edit update destroy]

  def index
    authorize User
    @users = policy_scope(User).includes(:roles).order(:name)
  end

  def new
    @user = User.new
    authorize @user
    @roles = assignable_roles
  end

  def create
    @user = User.new(user_params)
    authorize @user

    saved = User.transaction do
      @user.save && sync_roles(@user)
    end

    if saved
      redirect_to users_path, notice: "User #{@user.name} berhasil dibuat."
    else
      @roles = assignable_roles
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
    @roles = assignable_roles
  end

  def update
    authorize @user

    saved = User.transaction do
      @user.update(user_params) && sync_roles(@user)
    end

    if saved
      redirect_to users_path, notice: "User #{@user.name} berhasil diperbarui."
    else
      @roles = assignable_roles
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy!
    redirect_to users_path, notice: "User #{@user.name} dihapus."
  end

  private

  def set_user
    # lewat policy_scope: user tanpa hak tidak bisa membuka akun super admin via URL
    @user = policy_scope(User).find(params[:id])
  end

  def user_params
    permitted = params.require(:user).permit(:name, :email, :age, :password, :password_confirmation)
    # password kosong saat edit = tidak diubah
    permitted.delete_if { |k, v| k.start_with?("password") && v.blank? } if action_name == "update"
    permitted
  end

  # super_admin disembunyikan oleh RolePolicy::Scope untuk non-super-admin
  def assignable_roles
    policy_scope(Role).order(:name)
  end

  # Pasang role dari form. Mengembalikan true jika tidak ada yang perlu diubah.
  def sync_roles(user)
    return true unless params[:user]&.key?(:role_ids)
    return true unless policy(user).assign_roles?
    return true if user == current_user   # cegah mengunci/menaikkan diri sendiri

    ids = Array(params[:user][:role_ids]).compact_blank
    user.roles = assignable_roles.where(id: ids)   # whitelist: id di luar scope diabaikan
    true
  end
end