# See the OmniAuth documentation for the contents of this file.
#
#     https://github.com/intridea/omniauth
#     https://github.com/intridea/omniauth/wiki

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  provider :google_oauth2, Rails.application.secrets.google_client_id,
      Rails.application.secrets.google_client_secret,
      name: 'google', access_type: 'online', scope: 'email,profile',
      client_options: { :ssl => { :verify => false } }
end


OmniAuth.config.logger = Rails.logger
