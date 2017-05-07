class TripsController < ApplicationController
  before_action :set_trip, only: [:show]
  before_action :origin, only: [:index]
  before_action :set_trips, only: [:index]

  def index

  end

  def show
  end

  private

    def set_trip
      @trip = Trip.find(params[:id])
    end

    def set_trips
      miles=params[:miles] ? params[:miles].to_f : nil
      distance=params[:distance] ||= "false"
      reverse=params[:order] && params[:order].downcase=="desc"  #default to ASC

      @trip_segments=TripSegment.within_range(@origin, miles, reverse)
      @trip_segments=TripSegment.with_distance(@origin, @trip_segments) if distance.downcase=="true"

      @trips = Trip.where(id: @trip_segments.map(&:trip_id))
    end

    def origin
      case
      when params[:lng] && params[:lat]
        @origin=Point.new(params[:lng].to_f, params[:lat].to_f)
      else
        raise ActionController::ParameterMissing.new(
          "an origin [lng/lat] required")
      end
    end
end
