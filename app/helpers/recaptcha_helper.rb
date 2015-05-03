module RecaptchaHelper
  # This tries to follow the API of the recaptcha gem.
  def recaptcha_tags(options = {})
    site_key = options[:public_key] ||
               Rails.application.secrets['recaptcha_key']

    content_tag(:script, '', src: 'https://www.google.com/recaptcha/api.js',
                defer: true) +
        content_tag(:div, '', class: 'g-recaptcha',
                    data: { sitekey: site_key })
  end
end
