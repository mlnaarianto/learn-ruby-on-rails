# db/seeds.rb

# ============ PERMISSIONS (sumber kebenaran ada di kode) ============
resources = {
  "users"       => %w[index create update destroy],
  "posts"       => %w[index create update destroy],
  "roles"       => %w[index create update destroy manage_permissions],   # BARU: manage_permissions
  "permissions" => %w[index]
}

resources.each do |group, actions|
  actions.each do |action|
    Permission.find_or_create_by!(name: "#{group}.#{action}") do |p|
      p.group = group
    end
  end
end
puts "✅ Permission: #{Permission.count}"

# ============ ROLES ============
super_admin_role = Role.find_or_create_by!(name: "super_admin") { |r| r.description = "Bypass semua permission" }
admin_role       = Role.find_or_create_by!(name: "admin")       { |r| r.description = "Admin, permission diatur lewat UI" }
member_role      = Role.find_or_create_by!(name: "member")      { |r| r.description = "User standar" }

# ============ ROLE PERMISSIONS ============
# Admin mendapat semua permission (termasuk roles.manage_permissions)
Permission.find_each do |perm|
  RolePermission.find_or_create_by!(role: admin_role, permission: perm)
end

# Member hanya boleh lihat dan buat post
%w[posts.index posts.create].each do |name|
  perm = Permission.find_by!(name: name)
  RolePermission.find_or_create_by!(role: member_role, permission: perm)
end

puts "✅ Role: #{Role.pluck(:name).join(', ')}"
puts "✅ Admin: #{admin_role.permissions.count} permission | Member: #{member_role.permissions.count} permission"

# ============ SUPER ADMIN ============
super_admin_email = ENV.fetch("SUPER_ADMIN_EMAIL", "superadmin@example.com")

super_admin_password = ENV.fetch("SUPER_ADMIN_PASSWORD") do
  raise "SUPER_ADMIN_PASSWORD wajib diisi di production" if Rails.env.production?
  "password"   # hanya untuk development/test
end

super_admin = User.find_or_initialize_by(email: super_admin_email)

if super_admin.new_record?
  super_admin.assign_attributes(
    name:                  "Super Admin",
    password:              super_admin_password,
    password_confirmation: super_admin_password,
    age:                   30
  )
  super_admin.save!   # after_create otomatis memasang role "member"
  puts "✅ Super admin dibuat: #{super_admin_email}"
else
  puts "ℹ️  Super admin sudah ada: #{super_admin_email} (skip buat user)"
end

# Pasang role super_admin (idempotent)
UserRole.find_or_create_by!(user: super_admin, role: super_admin_role)
puts "✅ Role super_admin terpasang ke #{super_admin.email}"

puts "📊 User: #{User.count} | Role: #{Role.count} | Permission: #{Permission.count}"