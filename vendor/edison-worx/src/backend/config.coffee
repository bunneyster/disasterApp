fs = require 'fs'
path = require 'path'

# The backend configuration.
class Config
  # @property {Promise<Boolean>} resolved with true when the configuration is
  #   available
  ready: null

  # @property {String} the server URL
  serverUrl: null

  # @property {Object<String, String>} identity information for the server
  identity: null

  constructor: ->
    @_configDir = path.join process.env['HOME'], '.edison-cup'
    @_serverFile = path.join @_configDir, 'server.url'
    @_identityFile = path.join @_configDir, 'identity.json'
    @serverUrl = null
    @identity = null
    @_resolveReady = null
    @ready = new Promise (resolve, reject) =>
      @_resolveReady = resolve

  # Reads the configuration persisted to disk.
  #
  # @return {Promise<Boolean>} resolved with true when the configuration is
  #   available
  initialize: ->
    @_ensureDirExists()
      .then =>
        @_readServerFile()
      .then =>
        @_readIdentityFile()

  # Updates the board's identity.
  #
  # @param {Object} identity the board's new identity
  # @return {Promise<Boolean>} resolved with true when the configuration is
  #   updated
  setIdentity: (identity) ->
    @identity = identity
    @_writeIdentityFile()

  # Makes sure that the configuration directory exists.
  #
  # @return {Promise<Boolean>} resolved with true when the configuration
  #   directory is guaranteed to exist
  _ensureDirExists: ->
    new Promise (resolve, reject) =>
      fs.exists @_configDir, (exists) =>
        if exists
          resolve true
          return
        fs.mkdir @_configDir, (error) =>
          if error
            reject error
            return
          resolve true

  # Reads the config file that contains the server URL.
  #
  # @return {Promise<String>} resolved with the server URL
  _readServerFile: ->
    new Promise (resolve, reject) =>
      fs.exists @_serverFile, (exists) =>
        if exists
          fs.readFile @_serverFile, encoding: 'utf8', (error, data) =>
            if error
              reject error
              return
            @serverUrl = data.trim()
            resolve @serverUrl
        else
          @serverUrl = 'https://locky.herokuapp.com'
          @_writeServerFile()
            .then =>
              resolve @serverUrl
            .catch (error) ->
              reject error
          null

  # Reads the file that contains the board's identity.
  #
  # @return {Promise<Object>} resolved with the board's identity
  _readIdentityFile: ->
    new Promise (resolve, reject) =>
      fs.exists @_identityFile, (exists) =>
        unless exists
          @identity = null
          resolve @identity
          return

        fs.readFile @_identityFile, encoding: 'utf8', (error, data) =>
          if error
            reject error
            return
          try
            json = JSON.parse data
          catch jsonError
            reject jsonError
            return
          if json.server is @serverUrl
            @identity = json.identity
          else
            @identity = null
          resolve @identity

  # Writes the server URL to its config file.
  #
  # @return {Promise<Boolean>} resolved with true when the server URL file has
  #   been written
  _writeServerFile: ->
    new Promise (resolve, reject) =>
      fs.writeFile @_serverFile, @serverUrl, encoding: 'utf-8', (error) ->
        if error
          reject error
          return
        resolve true
      return

  # Writes the board's identity to its config file.
  #
  # @return {Promise<Boolean>} resolved with true when the board identity has
  #   been written
  _writeIdentityFile: ->
    new Promise (resolve, reject) =>
      data = JSON.stringify server: @serverUrl, identity: @identity
      fs.writeFile @_identityFile, data, encoding: 'utf-8', (error) ->
        if error
          reject error
          return
        resolve true
      return


module.exports = Config
