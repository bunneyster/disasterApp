json.array! @venues do |venue|
  json.id venue.id
  json.name venue.name
  json.lat venue.lat
  json.long venue.long
  json.icon_name venue.sensors['icon']
  json.icon_url venue_icon_url(venue)
end
