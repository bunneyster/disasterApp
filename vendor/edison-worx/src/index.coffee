require('es6-promise').polyfill()

Backend = require './backend.coffee'
Controller = require './controller.coffee'
Devices = require './devices.coffee'
LedBlinker = require './led_blinker.coffee'
WebController = require './web_controller.coffee'

backend = new Backend()
devices = new Devices()
blinkers =
  red: new LedBlinker devices.redLed
  blue: new LedBlinker devices.blueLed
  green: new LedBlinker devices.greenLed
controller = new Controller backend, devices, blinkers
webController = new WebController backend, devices, blinkers

###
backend.initialize()
  .then ->
    devices.initialize()
  .then ->
    devices.lcd.info 'Initializing', 'Controller'
    controller.initialize()
  .then ->
    controller.startSensing()
    devices.lcd.info 'Boot', 'Completed'
  .catch (error) ->
    console.error "BACKEND INIT FAILED: #{error}"
    console.error error.stack
    process.exit 1
###

devices.initialize()
  .then ->
    webController.initialize()
  .then ->
    console.log "Started up"
  .catch (error) ->
    console.error "BACKEND INIT FAILED: #{error}"
    console.error error.stack
    process.exit 1
