# TODO(pwnall): re-enable this when we can use the recaptcha gem

=begin
Recaptcha.configure do |config|
  config.public_key  = Rails.application.secrets['recaptcha_key']
  config.private_key = Rails.application.secrets['recaptcha_secret']
  config.use_ssl_by_default = true
end
=end
