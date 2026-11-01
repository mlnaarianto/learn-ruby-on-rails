# app/models/role.rb
class Role < ApplicationRecord
  # Role yang dirujuk langsung oleh kode, tidak boleh dihapus
  PROTECTED_NAMES = [ User::SUPER_ADMIN_ROLE, "member" ].freeze

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  # "Content Editor " -> "content_editor", supaya nama konsisten
  before_validation { self.name = name.to_s.strip.downcase.gsub(/\s+/, "_").presence }

  validates :name, presence: true,
                   uniqueness: true,
                   format: { with: /\A[a-z0-9_]+\z/, message: "hanya boleh huruf kecil, angka, dan underscore" }

  # Pengaman di level model (policy sudah menjaga di level UI)
  before_destroy :prevent_protected_destroy

  def protected?
    PROTECTED_NAMES.include?(name)
  end

  private

  def prevent_protected_destroy
    return unless protected?

    errors.add(:base, "Role #{name} tidak boleh dihapus")
    throw :abort
  end
end
