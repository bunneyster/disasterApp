GroveWater = require 'jsupm_grovewater'

# A grove water sensor.
class Water
  # @param {Number} dPort the D port that the water sensor is connected to
  constructor: (dPort) ->
    @_water = new GroveWater.GroveWater dPort

  # @return {Number} 1 if the sensor detects water, -1 otherwise
  value: ->
    if @_water.isWet() then 1 else -1


module.exports = Water
