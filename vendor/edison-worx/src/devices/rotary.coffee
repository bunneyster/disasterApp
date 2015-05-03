grove = require 'jsupm_grove'

# A grove rotary sensor.
class Rotary
  # @param {Number} aioPort the asynchronous IO port that the rotary sensor is
  #   connected to
  constructor: (aioPort) ->
    @_grove = new grove.GroveRotary aioPort

  # @return {Number} the sensor's rotation, in degrees
  value: ->
    @_grove.abs_deg()


module.exports = Rotary
