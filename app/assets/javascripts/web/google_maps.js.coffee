class GoogleMapClass
  constructor: ->
    @_domRoot = null
    @_mapsInitialized = false
    @_booted = false
    @_map = null
    @_markers = {}
    @_venues = {}

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
    options =
        center: { lat: -34.397, lng: 150.644 },
        zoom: 13
    @_map = new google.maps.Map(@_domRoot, options)
    @_infoWindow = new google.maps.InfoWindow()
    @_bootGeolocation()
    @_readVenues()

  _readVenues: ->
    Liveworx.Venues.readAll()
        .then (venues) =>
          @_processVenue(venue) for venue in venues

  _processVenue: (venue) ->
    @_venues[venue.id] = venue
    oldMarker = @_markers[venue.id]
    return if oldMarker

    marker = new google.maps.Marker(
        map: @_map,
        position: new google.maps.LatLng(venue.lat, venue.long)
        title: venue.name)
    google.maps.event.addListener marker, 'click',
        @_onMarkerClick.bind(@, venue.id)

    @_markers[venue.id] = marker

  _onMarkerClick: (venueId, event) ->
    venue = @_venues[venueId]
    @_infoWindow.close()
    @_infoWindow = new google.maps.InfoWindow(content: venue.name)
    @_infoWindow.open @_map, @_markers[venueId]

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

    @_infoWindow = new google.maps.InfoWindow(content: content)

window.Liveworx ||= {}
window.Liveworx.GoogleMap = new GoogleMapClass()
window.__googleMapsInitialized = ->
  Liveworx.GoogleMap.onMapsInitialized()

$ ->
  container = $ '#google-maps-container'
  if container.length > 0
    Liveworx.GoogleMap.onMapsDomRoot container[0]
