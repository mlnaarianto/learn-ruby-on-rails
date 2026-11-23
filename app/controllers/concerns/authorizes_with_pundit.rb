# app/controllers/concerns/authorizes_with_pundit.rb
module AuthorizesWithPundit
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!

    after_action :verify_authorized
    after_action :verify_policy_scoped, if: -> { action_name == "index" }
  end
end