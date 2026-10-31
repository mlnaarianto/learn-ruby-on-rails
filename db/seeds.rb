# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# db/seeds.rb

# ============ PERMISSIONS (sumber kebenaran ada di kode) ============
RESOURCES = {
  "users"       => %w[index create update destroy],
  "posts"       => %w[index create update destroy],
  "roles"       => %w[index create update destroy],
  "permissions" => %w[index]
}.freeze

RESOURCES.each do |group, actions|
  actions.each do |action|
    Permission.find_or_create_by!(name: "#{group}.#{action}") do |p|
      p.group = group
    end
  end
end
puts "✅ Permission: #{Permission.count}"

# ============ ROLES ============
admin_role  = Role.find_or_create_by!(name: "admin")  { |r| r.description = "Akses penuh ke seluruh sistem" }
member_role = Role.find_or_create_by!(name: "member") { |r| r.description = "User standar" }

# Admin selalu punya SEMUA permission (otomatis ikut bertambah tiap seed dijalankan)
admin_role.permissions = Permission.all

# Member: hanya permission awal. Pakai find_or_create supaya perubahan dari UI tidak tertimpa
%w[posts.index posts.create].each do |name|
  perm = Permission.find_by!(name: name)
  RolePermission.find_or_create_by!(role: member_role, permission: perm)
end
puts "✅ Role: #{Role.pluck(:name).join(', ')}"

# ============ SUPER ADMIN ============
super_admin = User.find_or_initialize_by(email: "superadmin@example.com")

if super_admin.new_record?
  super_admin.assign_attributes(
    name:                  "Super Admin",
    password:              ENV.fetch("SUPER_ADMIN_PASSWORD", "password"),
    password_confirmation: ENV.fetch("SUPER_ADMIN_PASSWORD", "password"),
    age:                   30
  )
  super_admin.save!
  puts "✅ Super admin dibuat: superadmin@example.com"
else
  puts "ℹ️  Super admin sudah ada: superadmin@example.com (skip buat user)"
end

# Pasang role admin (idempotent, aman dijalankan berulang)
UserRole.find_or_create_by!(user: super_admin, role: admin_role)
puts "✅ Role admin terpasang ke #{super_admin.email}"

puts "📊 Total user: #{User.count} | Role: #{Role.count} | Permission: #{Permission.count}"