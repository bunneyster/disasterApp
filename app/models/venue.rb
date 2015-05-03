require 'json'
require 'net/http'
require 'net/https'
require 'uri'

class Venue < ActiveRecord::Base
  # User-visible name for the venue.
  validates :name, presence: true, length: 1..128

  # The latitude of the venue's location.
  validates :lat, presence: true

  # The longitude of the venue's location.
  validates :long, presence: true, uniqueness: { scope: :lat }

  # The sensor readings.
  serialize :sensors, JSON

  # Create new venues in Thingworx.
  def self.create_venue_in_thingworx!
    create_things_in_thingworx!('TestVenue', 'VenueTemplate', 'DescriptionTest')
  end

  # Create things in Thingworx.
  def self.create_things_in_thingworx!(thing_name, base_template, description)
    uri = URI "http://live11.twplatform.com/Thingworx/Resources/EntityServices/Services/CreateThing?method=post&name=#{thing_name}&thingTemplateName=#{base_template}&description=#{description}"

    request = Net::HTTP::Post.new uri
    request.basic_auth 'Administrator', 'admin'

    response = Net::HTTP.start uri.hostname, uri.port do |http|
      http.request request
    end
  end

  # Set property of thing in Thingworx.
  def self.set_property_in_thingworx!(thing_name, property_name, value)
    uri = URI "http://live11.twplatform.com/Thingworx/Things/#{thing_name}/Properties/#{property_name}?method=put&value=#{value}"

    request = Net::HTTP::Post.new uri
    request.basic_auth 'Administrator', 'admin'

    response = Net::HTTP.start uri.hostname, uri.port do |http|
      http.request request
    end
  end

  # Set location property of thing in Thingworx.
  def self.set_location_property_in_thingworx!(thing_name, lat, long)
    uri = URI "http://live11.twplatform.com/Thingworx/Things/#{thing_name}/Properties/location?method=put&value=#{lat},%20­#{long}"

    request = Net::HTTP::Post.new uri
    request.basic_auth 'Administrator', 'admin'

    response = Net::HTTP.start uri.hostname, uri.port do |http|
      http.request request
    end
  end


  # Updates the database with venue information from Thingworx.
  def self.reload_from_thingworx!
    raw_venues = read_from_thingworx!
    raw_venues.map do |raw_venue|
      venue = Venue.where(lat: raw_venue[:lat], long: raw_venue[:long]).
          first_or_initialize
      venue.update_attributes raw_venue
      venue.save
      venue
    end
  end

  # Reads venue data from Thingworx.
  def self.read_from_thingworx!
    read_instances_from_thingworx!('VenueTemplate') +
        read_instances_from_thingworx!('CleanVenueTemplate')
  end

  def self.read_instances_from_thingworx!(class_name)
    uri = URI "http://live11.twplatform.com/Thingworx/ThingTemplates/#{class_name}/Services/GetImplementingThingsWithData"

    request = Net::HTTP::Post.new uri
    request.basic_auth 'Administrator', 'admin'
    request['Accept'] = 'application/json'

    response = Net::HTTP.start uri.hostname, uri.port do |http|
      http.request request
    end

    json = JSON.parse response.body
    json['rows'].map do |row|
      {
        lat: row['Location']['latitude'],
        long: row['Location']['longitude'],
        name: row['ui_name'],
        sensors: {
          hasFood: row['hasFood'],
          hasHeat: row['hasHeat'],
          hasPower: row['hasPower'],
          hasWater: row['hasWater'],
          icon: row['image'].downcase,
          light: row['LightSensor'],
          people: row['peopleCount'],
          food: row['Rotary'],
          temperature: row['Temperature'],
          water: row['Water'],
        },
      }
    end
  end
end
