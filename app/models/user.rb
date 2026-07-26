# app/models/user.rb
class User < ApplicationRecord
  # Tidak perlu ada method self.from_omniauth lagi di sini
  
  # Validasi standar tetap bisa ditambahkan di sini
  validates :email, presence: true
end