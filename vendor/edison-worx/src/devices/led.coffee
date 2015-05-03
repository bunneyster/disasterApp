Grove = require 'jsupm_grove'

# A grove LED.
class Led
  # Initializes the LED.
  #
  # The constructor turns off the LED, to get it into a known state.
  #
  # @param {Number} dPort the D port that the LED is connected to
  constructor: (dPort) ->
    @_led = new Grove.GroveLed dPort
    @_led.off()
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
    if lightOn
      @_led.on()
    else
      @_led.off()
    return


module.exports = Led
