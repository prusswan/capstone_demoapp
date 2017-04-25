class Image < ActiveRecord::Base
  include Protectable
  attr_accessor :image_content

  has_many :thing_images, inverse_of: :image, dependent: :destroy
  has_many :things, through: :thing_images
  has_one :user, inverse_of: :avatar

  scope :with_users, -> { where(id: User.with_images.pluck(:image_id).uniq) }
  scope :without_users, -> { where.not(id: User.with_images.pluck(:image_id).uniq) }

  composed_of :position,
              class_name:"Point",
              allow_nil: true,
              mapping: [%w(lng lng), %w(lat lat)]

  acts_as_mappable
  def to_lat_lng
    Geokit::LatLng.new(lat,lng)
  end

  def basename
    caption || "image-#{id}"
  end
end

Point.class_eval do
  def to_lat_lng
    Geokit::LatLng.new(*latlng)
  end
end
