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
    @_myLatlng = new google.maps.LatLng(-25.363882, 131.044922);
    options =
        center: @_myLatlng,
        zoom: 4
    @_map = new google.maps.Map(@_domRoot, options)

    @_contentString = '<div id="content">'+
      '<div id="siteNotice">'+
      '</div>'+
      '<h1 id="firstHeading" class="firstHeading">Uluru</h1>'+
      '<div id="bodyContent">'+
      '<p><b>Uluru</b>, also referred to as <b>Ayers Rock</b>, is a large ' +
      'sandstone rock formation in the southern part of the '+
      'Northern Territory, central Australia. It lies 335&#160;km (208&#160;mi) '+
      'south west of the nearest large town, Alice Springs; 450&#160;km '+
      '(280&#160;mi) by road. Kata Tjuta and Uluru are the two major '+
      'features of the Uluru - Kata Tjuta National Park. Uluru is '+
      'sacred to the Pitjantjatjara and Yankunytjatjara, the '+
      'Aboriginal people of the area. It has many springs, waterholes, '+
      'rock caves and ancient paintings. Uluru is listed as a World '+
      'Heritage Site.</p>'+
      '<p>Attribution: Uluru, <a href="https://en.wikipedia.org/w/index.php?title=Uluru&oldid=297882194">'+
      'https://en.wikipedia.org/w/index.php?title=Uluru</a> '+
      '(last visited June 22, 2009).</p>'+
      '</div>'+
      '</div>'

    @_infowindow = new google.maps.InfoWindow({
      content: @_contentString
    });

    @_marker = new google.maps.Marker({
      position: @_myLatlng,
      map: @_map,
      title: 'Uluru (Ayers Rock)'
    });

    google.maps.event.addListener @_marker, 'click', =>
      @_infowindow.open @_map, @_marker

window.Liveworx ||= {}
window.Liveworx.GoogleMap = new GoogleMapClass()
window.__googleMapsInitialized = ->
  Liveworx.GoogleMap.onMapsInitialized()

$ ->
  container = $ '#google-maps-container'
  if container.length > 0
    Liveworx.GoogleMap.onMapsDomRoot container[0]
