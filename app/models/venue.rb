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

  # The venue's name in Thingworx.
  validates :twx_name, length: { in: 1..256, allow_nil: true }

  # The venue's address.
  validates :address, length: { in: 1..128, allow_nil: true }

  # The venue's phone number, without any formatting.
  validates :phone, length: { in: 1..32, allow_nil: true }

  # The sensor readings.
  serialize :sensors, JSON

  # Updates a property in Thingworx.
  def set_thingworx_property(property_name, property_value)
    tname = URI.encode_www_form_component twx_name
    pname = URI.encode_www_form_component property_name
    pvalue = URI.encode_www_form_component property_value
    uri = URI('http://live11.twplatform.com/Thingworx/Things/' +
        "#{tname}/Properties/#{pname}?value=#{pvalue}")

    request = Net::HTTP::Put.new uri
    request.basic_auth 'Administrator', 'admin'
    request['Accept'] = 'application/json'

    Net::HTTP.start uri.hostname, uri.port do |http|
      http.request request
    end
  end

  def get_thingworx_property(property_name)
    tname = URI.encode_www_form_component twx_name
    pname = URI.encode_www_form_component property_name
    uri = URI('http://live11.twplatform.com/Thingworx/Things/' +
        "#{tname}/Properties/#{pname}")

    request = Net::HTTP::Get.new URI(uri)
    request.basic_auth 'Administrator', 'admin'
    request['Accept'] = 'application/json'

    response = Net::HTTP.start uri.hostname, uri.port do |http|
      http.request request
    end
    json = JSON.parse response.body
    json['rows'].first[property_name]
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
        twx_name: row['name'],
        phone: row['phone'],
        address: row['address'],
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
          userWarnings: row['userWarnings'],
        },
      }
    end
  end
end
