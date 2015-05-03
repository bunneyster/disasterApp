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
    @_lastInfoWindow = null
    @_lastInfoVenueId = null

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
    @_bootGeolocation()
    @_readVenues()

  _readVenues: ->
    Liveworx.Venues.readAll()
        .then (venues) =>
          @_processVenue(venue) for venue in venues
          if @_lastInfoWindow isnt null
            @_showInfoWindow @_lastInfoVenueId
          setTimeout @_readVenues.bind(@), 5000
        .catch (error) =>
          console.error error
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
    @_showInfoWindow venueId

  _hideLastInfoWindow: ->
    @_lastInfoWindow.close()
    @_lastInfoWindow = null
    @_lastInfoVenueId = null

  _showInfoWindow: (venueId) ->
    venue = @_venues[venueId]
    if @_lastInfoWindow isnt null
      @_hideLastInfoWindow()

    infoWindow = new google.maps.InfoWindow(
        content: @_getMarkerContent(venue))
    infoWindow.open @_map, @_markers[venueId].googleMarker()
    google.maps.event.addListener infoWindow, 'closeclick', =>
      @_lastInfoWindow = null
      @_lastInfoVenueId = null

    @_lastInfoWindow = infoWindow
    @_lastInfoVenueId = venueId

  _getMarkerContent: (venue) ->
    pieces = [
      "<div class='venue-popup'>",
      "<h5 class='popup-name'>#{venue.name}</h5>",
      "<div class='popup-icon-wrapper'>"]
    for filterName, value of venue.filters
      continue unless value
      pieces.push "<img src='assets/" + filterName + "_48x.png' width='25px' height'25px'>"

    phone = (venue.phone or '').replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3")
    pieces.push("</div>")
    pieces.push("<p class='popup-field'><i class='fa fa-globe'></i> #{venue.address}</p>")
    pieces.push("<p class='popup-field'><i class='fa fa-phone'></i> #{phone}</p>")
    pieces.push("<p class='popup-field'><i class='fa fa-male'></i> #{venue.people}</p>")
    pieces.push("<p class='override-section popup-field'>")
    pieces.push("<a class='button alert radius' onclick='window.Liveworx.GoogleMap.onAddWarningClick()'><i class='fa fa-warning'></i> Report</a>")
    if venue.userWarnings is 1
      pieces.push("<span class='warning-count'>  (#{venue.userWarnings} person thinks this location is not safe.)</span>")
    else if venue.userWarnings > 1
      pieces.push("<span class='warning-count'>  (#{venue.userWarnings} people think this location is not safe.)</span>")
    pieces.push("</p></div>")
    pieces.join('')

  onAddWarningClick: ->
    venueId = @_lastInfoVenueId

    csrfHeaderName = $('meta[name="csrf-param"]').attr('content')
    csrfHeaderValue = $('meta[name="csrf-token"]').attr('content')
    headers = {}
    headers[csrfHeaderName] = csrfHeaderValue
    fetch("/venues/#{venueId}/add_warning",
          method: 'post', body: '', headers: headers)
        .then =>
          @_venues[venueId].userWarnings =
              (@_venues[venueId].userWarnings || 0) + 1
          if @_lastInfoVenueId is venueId
            @_showInfoWindow venueId
        .catch (error) ->
          console.error error

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
