json.extract! trip, :id, :name, :created_at, :updated_at
json.segments trip.segments do |segment|
  json.position segment.position
  json.trip_id trip.id
  json.image_id segment.image_id
  json.lat segment.lat
  json.lng segment.lng
  json.image_caption segment.caption
  json.image_content_url image_content_url(segment.image_id)
end
