class VenuesClass
  constructor: ->

  # @return {Promise<Array<Venue>>} resolved with an array of all venues from
  #   the server
  readAll: ->
    fetch('/venues.json')
        .then (response) =>
          response.json()

window.Liveworx ||= {}
window.Liveworx.Venues = new VenuesClass()
