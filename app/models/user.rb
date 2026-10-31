# app/models/user.rb
class User < ApplicationRecord
  has_secure_password validations: false   # matikan validasi password otomatis (untuk user OAuth)

  # RBAC
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name,  presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :password, presence: true, if: -> { provider.blank? && password_digest.blank? }

  before_save { self.email = email.downcase.strip }
  after_create :assign_default_role

  def can?(permission_name)
    permission_names.include?(permission_name.to_s)
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  private

  def permission_names
    @permission_names ||= Permission
      .joins(:roles).where(roles: { id: role_ids })
      .distinct.pluck(:name).to_set
  end

  def assign_default_role
    role = Role.find_by(name: "member")
    roles << role if role
  end
end