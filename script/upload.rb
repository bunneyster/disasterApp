#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'net/https'
require 'uri'

def do_post(service_uri)
  uri = URI service_uri

  request = Net::HTTP::Post.new uri
  request.basic_auth 'Administrator', 'admin'

  Net::HTTP.start uri.hostname, uri.port do |http|
    http.request request
  end
end

def do_put(service_uri)
  uri = URI service_uri

  request = Net::HTTP::Put.new uri
  request.basic_auth 'Administrator', 'admin'

  Net::HTTP.start uri.hostname, uri.port do |http|
    http.request request
  end
end

def create_thing(thing_name, base_template, description)
  uri = 'http://live11.twplatform.com/Thingworx/Resources/EntityServices/' +
      'Services/CreateThing?' + URI.encode_www_form(
          name: thing_name, thingTemplateName: base_template,
          description: description
      )
  do_post uri
end

def enable_thing(thing_name)
  tname = URI.encode_www_form_component thing_name
  uri = 'http://live11.twplatform.com/Thingworx/Things/' +
      "#{tname}/Services/EnableThing"
  do_post uri
end

def restart_thing(thing_name)
  tname = URI.encode_www_form_component thing_name
  uri = 'http://live11.twplatform.com/Thingworx/Things/' +
      "#{tname}/Services/RestartThing"
  do_post uri
end

def set_property(thing_name, property_name, property_value)
  tname = URI.encode_www_form_component thing_name
  pname = URI.encode_www_form_component property_name
  pvalue = URI.encode_www_form_component property_value
  uri = 'http://live11.twplatform.com/Thingworx/Things/' +
      "#{tname}/Properties/#{pname}?value=#{pvalue}"
  p uri
  do_put uri
end

def write_business(json)
  venue_name = 'Yelp_' + json['yelp_id'].gsub('-', '_')
  if json['location']
    loc = "#{json['location']['lat']}, #{json['location']['long']}"
  else
    loc = ''
  end

  create_thing venue_name, 'VenueTemplate', 'Created by a wicked script'
  enable_thing venue_name
  restart_thing venue_name
  set_property venue_name, 'Location', loc
  set_property venue_name, 'ui_name', json['name']
  set_property venue_name, 'address', json['address']
  set_property venue_name, 'phone', json['phone']
  set_property venue_name, 'hasWater', rand < 0.75
  set_property venue_name, 'hasFood', rand < 0.5
  set_property venue_name, 'hasPower', rand < 0.25
  set_property venue_name, 'hasHeat', rand < 0.5
  set_property venue_name, 'peopleCount', rand(500).round
end

jsons = JSON.load File.read(File.expand_path('~/tmp/boston200.json'))
jsons.each { |j| write_business j }
