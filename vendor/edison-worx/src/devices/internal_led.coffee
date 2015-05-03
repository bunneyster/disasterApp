mraa = require 'mraa'

# The board's internal green LED.
#
# This class exposes the same API as the Led class.
class InternalLed
  # Initializes the LED.
  #
  # The constructor turns off the LED, to get it into a known state.
  constructor: ->
    @_gpio = new mraa.Gpio 13
    @_gpio.dir mraa.DIR_OUT
    @_gpio.write 0
    @_on = false

  # Returns the LED's current state.
  #
  # @return {Boolen} true if the LED is on, false if it's off
  isSet: ->
    @_on

  # Turns the LED on or off.
  #
  # @param {Boolean} on true if the LED should be turned on
  # @return undefined
  set: (lightOn) ->
    lightOn = !!lightOn
    return if @_on is lightOn is @_on
    @_on = lightOn
    @_gpio.write(if @_on then 1 else 0)
    return


module.exports = InternalLed

