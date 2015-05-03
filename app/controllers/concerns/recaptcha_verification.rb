module RecaptchaVerification
  # This tries to follow the API of the recaptcha gem.
  def verify_recaptcha(options = {})
    model = options[:model]
    attribute = options[:attribute] || base

    if params['g-recaptcha-response']
      query_params = {
        secret: Rails.application.secrets['recaptcha_secret'],
        response: params['g-recaptcha-response'],
        remoteip: request.remote_ip
      }
      uri = URI.parse 'https://www.google.com/recaptcha/api/siteverify?' +
                      URI.encode_www_form(query_params)

      begin
        response = Net::HTTP.get uri
        json = JSON.parse response
      rescue Net::HTTPError
        # We couldn't get to the API server.
        json = { 'error-codes' => ['network-error'] }
      rescue JSON::ParserError
        # The API server returned non-JSON.
        json = { 'error-codes' => ['json-parser-error'] }
      end
    else
      # We avoid API calls if the user doesn't interact with the reCAPTCHA.
      json = { 'error-codes' => ['missing-input-response'] }
    end

    return true if json['success']

    if json['error-codes']
      errors = json['error-codes'].join ', '
      error_message = "robot verificaion failed: #{errors}"
    else
      error_message = 'robot verification failed'
    end

    model.errors.add attribute, error_message
    false
  end
end
