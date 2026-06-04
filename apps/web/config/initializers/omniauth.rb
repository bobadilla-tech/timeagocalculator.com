# OmniAuth provider configuration.
# Add providers here when ready. Example:
#
#   Rails.application.config.middleware.use OmniAuth::Builder do
#     provider :google_oauth2,
#              ENV["GOOGLE_CLIENT_ID"],
#              ENV["GOOGLE_CLIENT_SECRET"]
#   end
#
# Each provider also needs:
#   - gem "omniauth-<provider>" in Gemfile
#   - GET  /auth/:provider/callback -> identities#create route
#   - IdentitiesController#create to find_or_create Identity + sign in user
