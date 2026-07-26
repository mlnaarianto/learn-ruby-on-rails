# app/services/oauth_authentication_service.rb
class OauthAuthenticationService
  # Menggunakan method class (self.call) agar bisa dipanggil tanpa inisiasi objek
  def self.call(auth_data)
    # Logika pencarian atau pembuatan user
    User.where(provider: auth_data.provider, uid: auth_data.uid).first_or_create do |user|
      user.email = auth_data.info.email
      user.name  = auth_data.info.name
      # Kolom age tetap dibiarkan kosong
    end
  rescue StandardError => e
    # Menangkap error jika database gagal menyimpan, menjaga stabilitas aplikasi
    Rails.logger.error("OAuth Error: #{e.message}")
    nil
  end
end