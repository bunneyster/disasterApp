# Controller that makes an LED blink.
class LedBlinker
  # @param {Led} led the LED that will blink
  constructor: (led) ->
    @_led = led
    @_blinkInterval = 500
    @_blinkUntil = null
    @_timeoutHandle = null
    @_ledState = null

  # Causes the LED to blink for a number of seconds.
  #
  # If the LED was already blinking, it'll blink for longer.
  #
  # @return undefined
  blinkFor: (seconds) ->
    @_blinkUntil = Date.now() + seconds * 1000
    if @_timeoutHandle is null
      @_ledState = false  # The timeout handle will flip this to true.
      @_onTimeout()
    return

  # @return {Boolean} true if this blinker is currently making the LED blink
  isBlinking: ->
    @_blinkUntil isnt null

  # Called when the blink timeout expires.
  _onTimeout: ->
    @_timeoutHandle = null
    if @_blinkUntil isnt null and Date.now() > @_blinkUntil
      @_blinkUntil = null
      @_ledState = null
      @_led.set false
      return

    @_ledState = !@_ledState
    @_led.set @_ledState
    @_timeoutHandle = setTimeout @_onTimeout.bind(@), @_blinkInterval


module.exports = LedBlinker
