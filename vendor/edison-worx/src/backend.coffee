W3gram = require 'w3gram'

Client = require './backend/client.coffee'
Config = require './backend/config.coffee'


# All the backend functionality.
class Backend
  # @property {Promise<Boolean}> resolves to true when the backend Web service
  #   is initialized and all properties are set to valid values
  ready: null

  # @property {Config} the backend configuration
  config: null

  # @property {Client} client for the backend Web service
  client: null

  # @property {W3Gram.PushRegistrationManager} client for the push service
  pushManager: null

  constructor: ->
    @config = new Config()
    @client = null
    @pushManager = null
    @pushRegistration = null
    @_resolveReady = null
    @_rejectReady = null
    @ready = new Promise (resolve, reject) =>
      @_resolveReady = resolve
      @_rejectReady = reject

  # Sets up all the backend structures.
  #
  # @return {Promise<Boolean>} resolved with true when the backend structures
  #   are configured
  initialize: ->
    if @_resolveReady is null
      return @_ready

    @config.initialize()
      .then =>
        @client = new Client @config.serverUrl
        @_ensureRegistered()
      .then =>
        console.error @config.identity
        @client.setIdentity @config.identity
      .then =>
        return true  # HACK: disable push cause WebSockets are blocked
        identity = @config.identity
        @pushManager = new W3gram.PushRegistrationManager identity.push
        @pushManager.register()
      .then (pushRegistration) =>
        return true # HACK: disable push cause WebSockets are blocked
        @pushRegistration = pushRegistration
        @client.updatePushInfo pushRegistration
      .then =>
        @_resolveReady true
        @_resolveReady = null
        @_rejectReady = null
      .catch (error) =>
        @_rejectReady error
        @_resolveReady = null
        @_rejectReady = null
    @ready

  # Makes sure that this board has an identity.
  #
  # @return {Promise<Boolean>} resolved to true when this board is guaranteed
  #   to have an identity
  _ensureRegistered: ->
    new Promise (resolve, reject) =>
      unless @config.identity is null
        resolve true
        return
      @client.register()
        .then (identity) =>
          @config.setIdentity identity
          resolve true
        .catch (error) ->
          reject error

module.exports = Backend
