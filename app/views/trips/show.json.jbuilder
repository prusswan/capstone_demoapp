json.extract! @trip, :id, :name, :created_at, :updated_at
json.segments @trip.segments do |segment|
  json.position segment.position
  json.image_id segment.image_id
  json.lat segment.lat
  json.lng segment.lng
end
