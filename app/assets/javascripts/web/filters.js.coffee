class FiltersClass
  # @property{function()} called when the UI selection of filters changes
  onChange: null

  # @property{Object<String, Boolean>} the UI selection of filters
  filters: null

  constructor: ->
    @filters = {}
    @_$domRoot = null
    @_$radios = []
    @onChange = null

  onDomRoot: ($domRoot) ->
    @_$domRoot = $domRoot
    $('[data-filter-value]', @_$domRoot).each (_, element) =>
      $radio = $ element
      filterName = $radio.attr 'data-filter-value'
      @_$radios[filterName] = $radio
    @_readRadios()
    @_$domRoot.on 'change', @_onRadioChange.bind(@)

  _readRadios: ->
    for filterName, $radio of @_$radios
      @filters[filterName] = $radio.is(':checked')

  _onRadioChange: ->
    @_readRadios()
    @onChange() if @onChange isnt null


window.Liveworx ||= {}
window.Liveworx.Filters = new FiltersClass
$ ->
  $container = $ '#filters-container'
  if $container.length > 0
    window.Liveworx.Filters.onDomRoot $container

