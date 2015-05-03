module VenuesHelper
  def venue_icon_url(venue)
    image_url("#{venue.sensors['icon']}_48x.png")
    people = venue.sensors['people']
    water = venue.sensors['hasWater']
    food = venue.sensors['hasFood']
    temp = venue.sensors['hasHeat']
    power = venue.sensors['hasPower']
    if water
      image_url('water_48x.png')
    elsif food
      image_url('food_48x.png')
    elsif temp
      image_url('heat_48x.png')
    elsif power
      image_url('power_48x.png')
    else
      image_url('trouble_48x.png')
    end
  end
end
