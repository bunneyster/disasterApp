mraa = require 'mraa'

# A grove touch sensor.
class Touch
  # @param {Number} dPort the D port that the water sensor is connected to
  constructor: (dPort) ->
    @_gpio = new mraa.Gpio dPort
    @_gpio.dir mraa.DIR_IN

  # @return {Number} 1 if the sensor detects water, -1 otherwise
  value: ->
    if @_gpio.read() > 0 then 1 else -1


module.exports = Touch
