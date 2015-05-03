I2CLCD = require 'jsupm_i2clcd'

# Interface to the I2C LCD.
class Lcd
  # Output an informational progress message.
  info: (line1, line2) ->
    @write line1, line2, 0, 0, 255

  # Output an error message.
  error: (line1, line2) ->
    @write line1, line2, 255, 0, 0

  # Sets up the LCD.
  constructor: ->
    @_lcd = new I2CLCD.Jhd1313m1 0, 0x3E, 0x62
    @_lineSize = 16
    @_red = null
    @_green = null
    @_blue = null


  # Sets the LCD's background color.
  #
  # The LCD's color is cached, and only modified when necessary.
  #
  # @param {Number} red 0-255
  # @param {Number} green 0-255
  # @param {Number} blue 0-255
  # @return undefined
  setBackground: (red, green, blue) ->
    return if @_red is red and @_green is green and @_blue is blue
    @_lcd.setColor red, green, blue
    @_red = red
    @_green = green
    @_blue = blue
    return

  # Writes an LCD message to the LCD.
  #
  # @return undefined
  write: (line1, line2, red, green, blue) ->
    @setBackground red, green, blue

    line1 = @_fixLine line1
    line2 = @_fixLine line2

    @_lcd.setCursor 0, 0
    @_lcd.write line1
    @_lcd.setCursor 1, 0
    @_lcd.write line2
    return

  # Return a string that matches the line size precisely.
  _fixLine: (line) ->
    line = '' if line is undefined or line is null
    if line.length < @_lineSize
      line += (new Array(@_lineSize - line.length + 1)).join ' '
    else if line.length > @_lineSize
      line = line.substring 0, 16

  # Clears the LCD.
  #
  # @return undefined
  clear: ->
    @_lcd.clear()

module.exports = Lcd
