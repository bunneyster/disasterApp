class CachedMarker
  constructor: ->
    @_marker = new google.maps.Marker()
    @_s = { map: null, iconUrl: null, lat: null, long: null, title: null }

  googleMarker: ->
    @_marker

  setMap: (newMap) ->
    return if newMap is @_s.map
    @_s.map = newMap
    @_marker.setMap newMap

  setIcon: (newIcon) ->
    return if newIcon.url is @_s.iconUrl
    @_s.iconUrl = newIcon.url
    @_marker.setIcon newIcon

  setPosition: (newPosition) ->
    lat = newPosition.lat()
    long = newPosition.lng()
    return if lat is @_s.lat and long is @_s.long
    @_s.lat = lat
    @_s.long = long
    @_marker.setPosition newPosition

  setTitle: (newTitle) ->
    return if newTitle is @_s.title
    @_s.title = newTitle
    @_marker.setTitle newTitle

class GoogleMapClass
  constructor: ->
    @_domRoot = null
    @_mapsInitialized = false
    @_booted = false
    @_map = null
    @_filters = {}
    @_markers = {}
    @_venues = {}

  onMapsInitialized: ->
    @_mapsInitialized = true
    @_tryBooting()

  onMapsDomRoot: (domRoot) ->
    @_domRoot = domRoot
    @_tryBooting()

  setFilters: (filters) ->
    @_filters = filters
    for _, venue of @_venues
      @_processVenue venue

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
          setTimeout @_readVenues.bind(@), 10000
        .catch (error) =>
          console.log error
          setTimeout @_readVenues.bind(@), 2000

  _processVenue: (venue) ->
    @_venues[venue.id] = venue
    if venue.id of @_markers
      marker = @_markers[venue.id]
    else
      marker = new CachedMarker()
      @_markers[venue.id] = marker
      google.maps.event.addListener marker.googleMarker(), 'click',
          @_onMarkerClick.bind(@, venue.id)

    if @_matchesFilters venue
      marker.setMap @_map
    else
      marker.setMap null
      return
    marker.setIcon(url: venue.icon_url)
    marker.setPosition new google.maps.LatLng(venue.lat, venue.long)
    marker.setTitle venue.name

  _matchesFilters: (venue) ->
    people = @_filters.people || 0
    if @_filters.nothing is true
      return false if venue.people < people
      for name, value of venue.filters
        return false if value is true
    else
      return false if venue.people < people
      for name, value of @_filters
        continue unless value is true
        return false if venue.filters[name] is false
    true

  _onMarkerClick: (venueId, event) ->
    venue = @_venues[venueId]
    @_infoWindow.close()
    @_infoWindow = new google.maps.InfoWindow(
        content: @_getMarkerContent(venue))
    @_infoWindow.open @_map, @_markers[venueId].googleMarker()

  _getMarkerContent: (venue) ->
    pieces = ["<div>#{venue.name}</div>"]
    for filterName, value of venue.filters
      continue unless value
      pieces.push "<img src='assets/" + filterName + "_48x.png' width='16px' height'16px'>"
    pieces.push("<p><i class='fa fa-male'> #{venue.people}</i></p>")
    pieces.join('')

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
    Liveworx.Filters.onChange = ->
      Liveworx.GoogleMap.setFilters Liveworx.Filters.filters
    Liveworx.GoogleMap.on
