module W3gramHelper
  def w3gram_setup_tag
    if @device
      device_info = {
        server: Rails.application.secrets.w3gram_url,
        key: Rails.application.secrets.w3gram_app,
        device: @device.key,
        token: @device.push_token
      }
      javascript_tag "W3gram.setupPushManager(#{device_info.to_json});"
    end
  end
end
