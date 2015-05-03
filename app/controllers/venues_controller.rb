class VenuesController < ApplicationController
  def index
    # TODO: be smarter about refreshing
    Venue.reload_from_thingworx!

    @venues = Venue.all
  end
end
