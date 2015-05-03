grove = require 'jsupm_grove'

# A grove light sensor.
class Light
  # @param {Number} aioPort the asynchronous IO port that the light sensor is
  #   connected to
  constructor: (aioPort) ->
    @_grove = new grove.GroveLight aioPort

  # @return {Number} the number of lumens received by the sensor
  value: ->
    @_grove.value()


module.exports = Light
