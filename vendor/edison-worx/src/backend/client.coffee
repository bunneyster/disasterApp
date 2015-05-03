request = require 'request'

# Client for the main backend server.
class Client
  # @param {String} serverUrl the main URL for the backend server
  constructor: (serverUrl) ->
    @_serverUrl = serverUrl
    @_key = null

  # Creates an identity for this board.
  #
  # @return {Promise<Object>} resolved with the board's identity
  register: ->
    cup_data =
      node_version: process.versions.node
    @_jsonRequest 'POST', "#{@_serverUrl}/cups.json", cup: cup_data

  # Plugs this board's identity into the client.
  #
  # @param {Object} identity this board's identity
  # @return undefined
  setIdentity: (identity) ->
    @_key = identity.key
    return

  # Sends this board's push registration to the backend server.
  #
  # @param {W3gram.PushRegistration} registration the board's push
  #   registration
  # @return {Promise<Boolean>} resolved with true
  updatePushInfo: (registration) ->
    url = "#{@_serverUrl}/cups/#{@_key}/push_info.json"
    cup_data =
      push_uid: registration.registrationId
      push_url: registration.endpoint
    @_jsonRequest('POST', url, cup: cup_data).then =>
      true

  # Sends this board's sensor information to the backend server.
  #
  # @param {Object} sensors sensor data to be sent to the backend
  # @return {Promise<Object>} resolves to the backend's reaction to the sensor
  #   information
  updateSensors: (sensors) ->
    url = "#{@_serverUrl}/cups/#{@_key}/sensors.json"
    @_jsonRequest('POST', url, sensors: sensors)

  # Issues a generic JSON request to the backend.
  #
  # @param {String} method the HTTP method (e.g., "GET")
  # @param {String} url the URL to send the request to
  # @param {Object?} json the JSON object to be sent as the request body; null
  #   if no object should be sent
  # @return {Promise<Object>} resolved with the backend's response
  _jsonRequest: (method, url, json, callback) ->
    new Promise (resolve, reject) =>
      options =
        method: method
        url: url
        headers:
          accept: 'application/json'
      if json is null
        unless method is 'GET'
          options.headers['content-type'] = 'text/plain'
          options.body = ''
      else
        options.headers['content-type'] = 'application/json'
        options.body = JSON.stringify json

      request options, (error, response, body) =>
        if error
          reject error
        try
          data = JSON.parse body
        catch jsonError
          reject jsonError
        resolve data


module.exports = Client
