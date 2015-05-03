class VenuesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:add_warning]

  def index
    # TODO: be smarter about refreshing
    Venue.reload_from_thingworx!

    @venues = Venue.all
  end

  # PATCH /venues/1/add_warning
  def add_warning
    @venue = Venue.where(id: params[:id]).first!
    oldValue = @venue.get_thingworx_property('userWarnings') || 0
    @venue.set_thingworx_property('userWarnings', oldValue + 1)

    respond_to do |format|
      format.json { render json: {} }
    end
  end
end
