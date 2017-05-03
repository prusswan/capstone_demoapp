class Trip < ActiveRecord::Base

  validates :name, presence: true

  has_many :segments, -> { order(:position) }, class_name: TripSegment

end
