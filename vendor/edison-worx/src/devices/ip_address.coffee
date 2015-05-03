os = require 'os'

# Virtual sensor reporting the board's IP address.
class IpAddress
  # Sets up the virtual sensor.
  constructor: ->
    null

  # @return {String} the board's IP address
  value: ->
    for name, netInterfaces of os.networkInterfaces()
      continue unless /^wlan/.test(name) || /^wireless /i.test(name)
      for netInterface in netInterfaces
        continue unless netInterface.family is 'IPv4'
        continue if netInterface.internal
        return netInterface.address
    'unknown'

module.exports = IpAddress
