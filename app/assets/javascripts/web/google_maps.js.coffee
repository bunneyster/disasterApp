class GoogleMapClass
  constructor: ->
    @_domRoot = null
    @_mapsInitialized = false
    @_booted = false
    @_map = null
    @_markers = {}

  onMapsInitialized: ->
    @_mapsInitialized = true
    @_tryBooting()

  onMapsDomRoot: (domRoot) ->
    @_domRoot = domRoot
    @_tryBooting()

  _tryBooting: ->
    return if @_booted
    return if @_domRoot is null or !@_mapsInitialized
    @_booted = true
    @_boot()

  _boot: ->
    console.log 'booting'
    @_myLatlng = new google.maps.LatLng(-34.397, 150.644);
    options =
        center: { lat: -34.397, lng: 150.644 },
        zoom: 12
    @_map = new google.maps.Map(@_domRoot, options)
    @_bootGeolocation()
    @_readVenues()

  _readVenues: ->
    Liveworx.Venues.readAll()
        .then (venues) =>
          @_processVenue(venue) for venue in venues

  _processVenue: (venue) ->
    unless venue.id of @_markers
      @_markers[venue.id] = new google.maps.Marker(
          map: @_map,
          position: new google.maps.LatLng(venue.lat, venue.long)
          title: venue.name)

  # Tries to center the map using the user's location.
  _bootGeolocation: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition(@_onLocation.bind(@),
          @_onLocationFailure.bind(@, true))
    else
      # Browser does not support Geolocation
      @_onLocationFailure false

  # Called when we get a result from the W3C geolocation API.
  _onLocation: (position) ->
    pos = new google.maps.LatLng(position.coords.latitude,
                                 position.coords.longitude)
    @_map.setCenter(pos)

  # Called when we fail to use the W3C geolocation API.
  #
  # @param {Boolean} errorFlag true when the browser supports the API, but the
  #   user didn't allow us to use it
  _onLocationFailure: (errorFlag) ->
    if errorFlag
      content = 'Error: The Geolocation service failed.'
    else
      content = 'Error: Your browser does not support geolocation.'

    infowindow = new google.maps.InfoWindow { content: content }

window.Liveworx ||= {}
window.Liveworx.GoogleMap = new GoogleMapClass()
window.__googleMapsInitialized = ->
  Liveworx.GoogleMap.onMapsInitialized()

$ ->
  container = $ '#google-maps-container'
  if container.length > 0
    Liveworx.GoogleMap.onMapsDomRoot container[0]
