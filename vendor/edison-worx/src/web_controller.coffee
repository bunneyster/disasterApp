errorHandler = require 'errorhandler'
express = require 'express'

# The Web front-end.
class WebController
  constructor: (backend, devices, blinkers) ->
    @_backend = backend
    @_devices = devices
    @_blinkers = blinkers
    @_initPromise = null
    @_port =  process.env.PORT || 8010

    @_app = express()
    @_app.use errorHandler()
    @_app.get '/hello', @_onHello.bind(@)
    @_app.get '/s/:sensor', @_onSensor.bind(@)
    @_app.get '/blink', @_onBlink.bind(@)

  # Starts the Web front-end.
  #
  # @return {Promise} resolved when the server is started up
  initialize: ->
    return @_initPromise unless @_initPromise is null

    @_initPromise = new Promise (resolve, reject) =>
      @_app.listen @_port, ->
        resolve true

  # GET /hello
  _onHello: (request, response) ->
    response.json message: 'Ohai from CoffeeScript'

  # GET /s/sensor
  _onSensor: (request, response) ->
    sensor = request.params.sensor
    if sensor of @_devices
      value = @_devices[sensor].value()
    else
      value = 'missing sensor'
    response.json value: value

  # GET /blink?color=green&seconds=3
  _onBlink: (request, response) ->
    console.log request.params
    color = request.params.color || request.query.color
    seconds = parseInt request.params.seconds || request.query.color
    if color of @_blinkers
      @_blinkers[color].blinkFor seconds
      value = 'ok'
    else
      value = 'missing LED'
    response.json value: value



module.exports = WebController
