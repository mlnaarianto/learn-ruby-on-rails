# app/controllers/concerns/authorizes_with_pundit.rb
module AuthorizesWithPundit
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!

    # Pengaman: error jika ada action yang lupa authorize / policy_scope
    after_action :verify_authorized
    after_action :verify_policy_scoped, only: :index
  end
end