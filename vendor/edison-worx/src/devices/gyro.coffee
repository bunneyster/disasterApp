Enc03r = require 'jsupm_enc03r'

# Lifted from Intel sample.
#     https://software.intel.com/en-us/node/541843
CALIBRATION_SAMPLES = 1000

class Gyro
  # @property {Promise<Boolean}} resolved with true when the gyroscope is
  #   calibrated
  ready: null

  # @param {Number} aioPort the asynchronous IO port that the gyroscope is
  #   connected to
  constructor: (aioPort) ->
    @_aioPort = aioPort
    @_gyro = new Enc03r.ENC03R aioPort
    @_resolveReady = null
    @ready = new Promise (resolve, reject) =>
      @_resolveReady = resolve

  # Starts calibrating the gyroscope.
  #
  # Gyroscope calibration is synchronous, so the promise will be resolved when
  # it is returned. Callers should not depend on that, as future
  # implementations may improve on that.
  #
  # @return {Promise} resolved when the gyroscope is calibrated
  initialize: ->
    unless @_resolveReady is null
      @_gyro.calibrate CALIBRATION_SAMPLES
      @_resolveReady true
      @_resolveReady = null
    @ready

  # Get the angular velocity from the gyroscope.
  #
  # @return {Number} angular velocity in degrees/second
  value: ->
    rawValue = @_gyro.value()
    @_gyro.angularVelocity @_gyro.value()


module.exports = Gyro
