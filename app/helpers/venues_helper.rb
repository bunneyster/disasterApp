module VenuesHelper
  def venue_icon_url(venue)
    #people = venue.sensors['people']
    water = venue.sensors['hasWater']
    food = venue.sensors['hasFood']
    temp = venue.sensors['hasHeat']
    power = venue.sensors['hasPower']
    if water
      image_url('water_pin.png')
    elsif food
      image_url('food_pin.png')
    elsif temp
      image_url('heat_pin.png')
    elsif power
      image_url('power_pin.png')
    else
      image_url('none_pin.png')
    end
  end
end
