# app/models/user.rb
class User < ApplicationRecord
  SUPER_ADMIN_ROLE = "super_admin".freeze

  has_secure_password validations: false

  # RBAC
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles,
                   after_add:    :reset_rbac_cache,     # STEP 3
                   after_remove: :reset_rbac_cache      # STEP 3

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name,  presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :password, presence: true, if: -> { provider.blank? && password_digest.blank? }

  before_save { self.email = email.downcase.strip }
  after_create :assign_default_role

  def super_admin?
    role_names.include?(SUPER_ADMIN_ROLE)
  end

  def can?(permission_name)
    return true if super_admin?
    permission_names.include?(permission_name.to_s)
  end

  def has_role?(role_name)
    role_names.include?(role_name.to_s)
  end

  def reload(*)                                         # STEP 3
    reset_rbac_cache
    super
  end

  private

  def role_names
    @role_names ||= roles.pluck(:name).to_set
  end

  def permission_names
    @permission_names ||= Permission
      .joins(:roles).where(roles: { id: role_ids })
      .distinct.pluck(:name).to_set
  end

  def reset_rbac_cache(_role = nil)                     # STEP 3
    @role_names = @permission_names = nil
  end

  def assign_default_role
    role = Role.find_by(name: "member")
    roles << role if role
  end
end