json.array! @venues do |venue|
  json.id venue.id
  json.name venue.name
  json.lat venue.lat
  json.long venue.long
end
