class TripSegment < ActiveRecord::Base

  validates_presence_of :trip_id, :position, :image_id

  validates :position, uniqueness: {scope: :trip_id, message: 'should be unique within a trip'}

end
