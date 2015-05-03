grove = require 'jsupm_grove'

# A grove temperature sensor.
class Temperature
  # @param {Number} aioPort the asynchronous IO port that the temperature
  #   sensor is connected to
  constructor: (aioPort) ->
    @_grove = new grove.GroveTemp aioPort

  # @return {Number} the sensor's temperature, in Celsius degrees
  value: ->
    @_grove.value()


module.exports = Temperature
