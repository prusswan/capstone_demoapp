# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Rake::Task['ptourist:reset_all'].invoke

image_ids = Image.select("distinct on (lat, lng) *")
  .reject{|i| i.lat.nil? || i.lng.nil?}
  .map(&:id)

(1..5).each do |count|
  t = Trip.find_or_create_by(name: "Trip #{count}")
  next if t.segments.present?

  places = image_ids.sample(7)
  TripSegment.transaction do
    places.each_with_index do |p, i|
      t.segments.create(position: i, image_id: p)
    end
  end
end
