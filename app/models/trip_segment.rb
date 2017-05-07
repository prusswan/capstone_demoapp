class TripSegment < ActiveRecord::Base

  validates_presence_of :trip_id, :position, :image_id

  validates :position, uniqueness: {scope: :trip_id, message: 'should be unique within a trip'}

  belongs_to :trip
  belongs_to :image
  delegate :lat, :lng, :caption, to: :image

  acts_as_mappable :through => :image

  scope :with_trip, ->{ joins("left outer join trips on trips.id = trip_segments.trip_id")
                         .select("trip_segments.*")}
  scope :with_image, ->{ joins("right outer join images on images.id = trip_segments.image_id")
                         .select("trip_segments.*","images.id as image_id")}

  scope :with_position,->{ with_image.select("images.lng, images.lat")}
  scope :within_range, ->(origin, limit=nil, reverse=nil) {
    scope=with_position
    scope=scope.within(limit,:origin=>origin)                   if limit
    scope=scope.by_distance(:origin=>origin, :reverse=>reverse) unless reverse.nil?
    return scope
  }

  def self.with_distance(origin, scope)
    scope.select("-1.0 as distance").with_position
         .each {|ti| ti.distance = ti.distance_from(origin) }
  end
end
