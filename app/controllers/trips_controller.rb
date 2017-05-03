class TripsController < ApplicationController
  before_action :set_trip, only: [:show]

  def index
    @trips = Trip.all
  end

  def show
  end

  private

    def set_trip
      @trip = Trip.find(params[:id])
    end

end
