Mq303a = require 'jsupm_mq303a'

class Alcohol
  # @property {Promise<Boolean>} resolved with true when the alcohol sensor is
  #   heated up
  ready: null

  # @param {Number} aioPort the asynchronous IO port that the alcohol sensor is
  #   connected to
  # @param {Number} heaterGpio the GPIO pin used to power the heater
  constructor: (aioPort, heaterGpio) ->
    @_alcohol = new Mq303a.MQ303A 0, 15
    @_pollInterval = 500
    # HACK: the heating reference should be 450, but that broke the demo
    @_heatingThreshold = 550

  # Waits until the alcohol sensor is heated.
  #
  # @param {Boolean} waitUntilHeated if false, the returned promise will only
  #   be resolved when the alcohol sensor appears to be heated; this requires that
  #   the sensor is present and in a non-alcoholic environment
  # @return {Promise} resolved when the alcohol sensor is heated up
  initialize: (skipHeating) ->
    @_alcohol.heaterEnable true

    if skipHeating
      return new Promise (resolve, reject) ->
        resolve true

    new Promise (resolve, reject) =>
      timeoutCallback = =>
        value = @_alcohol.value()
        if value < @_heatingThreshold
          resolve true
          return
        console.error(
            "Alcohol shows: #{value}  waiting for: #{@_heatingThreshold}")
        setTimeout timeoutCallback, @_pollInterval
      timeoutCallback()

  # Gets a reading from the alcohol sensor.
  #
  # @return {Number} the reading from the sensor
  value: ->
    @_alcohol.value()


module.exports = Alcohol
