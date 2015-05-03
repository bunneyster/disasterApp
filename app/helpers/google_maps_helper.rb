module GoogleMapsHelper
  def google_maps_include_tag
    api_key = Rails.application.secrets.google_maps_key

    content_tag :script, '',
        src: 'https://maps.googleapis.com/maps/api/js?' +
             "callback=__googleMapsInitialized&key=#{api_key}"
  end
end

