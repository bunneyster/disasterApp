noble = require 'noble'

# Virtual sensor that counts the number of bluetooth devices around.
class BtCount
  constructor: ->
    @_devices = {}
    @_deviceCount = 0

    noble.on 'discover', @_onDiscover.bind(@)
    noble.startScanning()

  _onDiscover: (peripheral) ->
    address = peripheral.address
    unless address in @_devices
      @_devices[address] = true
      @_deviceCount += 1

  value: ->
    @_deviceCount


module.exports = BtCount
