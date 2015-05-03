class GoogleMapClass
  constructor: ->
    @_domRoot = null
    @_mapsInitialized = false
    @_booted = false
    @_map = null

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
    options =
        center: { lat: -34.397, lng: 150.644},
        zoom: 8
    @_map = new google.maps.Map(@_domRoot, options)

window.Liveworx ||= {}
window.Liveworx.GoogleMap = new GoogleMapClass()
window.__googleMapsInitialized = ->
  Liveworx.GoogleMap.onMapsInitialized()

$ ->
  container = $ '#google-maps-container'
  if container.length > 0
    Liveworx.GoogleMap.onMapsDomRoot container[0]
