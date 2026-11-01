# app/policies/application_policy.rb
# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user   = user
    @record = record
  end

  def index?   = permitted?(:index)
  def show?    = permitted?(:index)   # lihat detail = izin index
  def create?  = permitted?(:create)
  def new?     = create?
  def update?  = permitted?(:update)
  def edit?    = update?
  def destroy? = permitted?(:destroy)

  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    # Default: tamu tidak melihat apa pun. Policy turunan memanggil `super` lalu menyaring.
    def resolve
      return scope.none if user.nil?

      scope.all
    end

    private

    attr_reader :user, :scope
  end

  private

  # Cek permission "<resource>.<action>", contoh "posts.update".
  # Super admin otomatis lolos karena bypass ada di User#can?
  def permitted?(action)
    return false if user.nil?

    user.can?("#{resource_name}.#{action}")
  end

  # PostPolicy -> "posts", Admin::RolePolicy -> "roles"
  def resource_name
    self.class.name.demodulize.delete_suffix("Policy").underscore.pluralize
  end

  # Pemilik record. Super admin tidak perlu ditangani di sini: cukup
  # pakai `permitted?(:manage_all) || owner?` (manage_all otomatis true untuk super admin).
  def owner?
    user.present? && record.respond_to?(:user_id) && record.user_id == user.id
  end
end
