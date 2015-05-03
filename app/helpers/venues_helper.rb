module VenuesHelper
  def venue_icon_url(venue)
    image_url("#{venue.sensors['icon']}_48x.png")
    people = venue.sensors['people']
    water = venue.sensors['water']
    food = venue.sensors['food']
    temp = venue.sensors['temperature']
    power = venue.sensors['light']
    if water > 0
      image_url('water_48x.png')
    elsif food > 0
      image_url('food_48x.png')
    elsif temp > 0
      image_url('heat_48x.png')
    elsif power > 0
      image_url('power_48x.png')
    else
      image_url('trouble_48x.png')
    end
  end
end
