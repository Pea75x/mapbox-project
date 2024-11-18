json.array!(@species_locations) do |species_location|
  json.locality species_location.locality
  json.scientific_name species_location.scientific_name
  json.scientific_name_id species_location.scientific_name_id
end