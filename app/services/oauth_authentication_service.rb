# app/services/oauth_authentication_service.rb
class OauthAuthenticationService
  def self.call(auth_data)
    user = User.find_or_initialize_by(
      provider: auth_data.provider,
      uid: auth_data.uid
    )

    user.email      = auth_data.info.email
    user.name       = auth_data.info.name
    user.avatar_url = auth_data.info.image
    user.save!
    user
  rescue StandardError => e
    Rails.logger.error("OAuth Error: #{e.message}")
    nil
  end
end