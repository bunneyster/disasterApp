class FiltersClass
  # @property{function()} called when the UI selection of filters changes
  onChange: null

  # @property{Object<String, Boolean>} the UI selection of filters
  filters: null

  constructor: ->
    @filters = {}
    @_$domRoot = null
    @_$radios = []
    @_$sliders = []
    @onChange = null

  onDomRoot: ($domRoot) ->
    @_$domRoot = $domRoot
    $('input[type="checkbox"][data-filter-value]', @_$domRoot).
        each (_, element) =>
          $radio = $ element
          filterName = $radio.attr 'data-filter-value'
          @_$radios[filterName] = $radio
    $('[data-slider][data-filter-value]', @_$domRoot).
        each (_, element) =>
          $slider = $ element
          filterName = $slider.attr 'data-filter-value'
          @_$sliders[filterName] = $slider
    @_readRadios()
    @_readSliders()
    @_$domRoot.on 'change', @_onRadioChange.bind(@)
    #@_$domRoot.on 'change.fndtn.slider', @_onSliderChange.bind(@)

  _readRadios: ->
    for filterName, $radio of @_$radios
      @filters[filterName] = $radio.is(':checked')

  _readSliders: ->
    for filterName, $slider of @_$sliders
      @filters[filterName] = $slider.attr('data-slider') || 0

  _onRadioChange: ->
    @_readRadios()
    @_readSliders()
    @onChange() if @onChange isnt null

  _onSliderChange: (event) ->
    @_readRadios()
    @_readSliders()
    @onChange() if @onChange isnt null
    true

window.Liveworx ||= {}
window.Liveworx.Filters = new FiltersClass
$ ->
  $container = $ '#filters-container'
  if $container.length > 0
    window.Liveworx.Filters.onDomRoot $container

