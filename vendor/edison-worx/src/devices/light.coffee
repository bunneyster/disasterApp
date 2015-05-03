grove = require 'jsupm_grove'

# A grove light sensor.
class Light
  # @param {Number} aioPort the asynchronous IO port that the light sensor is
  #   connected to
  constructor: (aioPort) ->
    @_grove = new grove.GroveLight aioPort

  # @return {Number} 1 if the sensor detects light, -1 otherwise
  value: ->
    if @_grove.value() > 0 then 1 else -1


module.exports = Light
