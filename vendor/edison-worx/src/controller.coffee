# Shuttles data around between the backend and the sensors.
class Controller
  constructor: (backend, devices, blinkers) ->
    @_backend = backend
    @_devices = devices
    @_blinkers = blinkers
    @_senseInterval = 1000
    @_senseIntervalHandler = null

  # Initializes the controller, after the backend and devices are set up.
  #
  # @return {Promise<Boolean>} resolves to true when the controller is
  #   initialized
  initialize: ->
    # HACK: push notifications can be disabled if WebSockets are blocked
    if @_backend.pushRegistration
      @_backend.pushRegistration.onpush = @_onPush.bind(@)

  # @return {Boolean} true if the controller's sensing loop is running
  startedSensing: ->
    @_senseIntervalHandler isnt null

  # Starts the sensing loop.
  #
  # @return undefined
  startSensing: ->
    return if @startedSensing()

    callback = =>
      return unless @startedSensing()
      @_onSenseInterval()
      return
    @_senseIntervalHandler = setInterval callback, @_senseInterval

  # Stops the sensing loop, if it was started.
  #
  # @return undefined
  stopSensing: ->
    return unless @startedSensing()
    cancelInterval @_senseIntervalHandler
    @_senseIntervalHandler = null
    return

  # One iteration of the sensing loop.
  #
  # @return undefined
  _onSenseInterval: ->
    sensors = @_devices.sensors()
    @_backend.client.updateSensors(sensors)
      .then (reaction) =>
        for blinkerName, blinkTime of reaction
          if blinker = @_blinkers[blinkerName]
            blinker.blinkFor blinkTime
    return

  # Called when a push notification is received.
  _onPush: (event) ->
    console.error "PUSH DATA: #{event.data}"
    return


module.exports = Controller
