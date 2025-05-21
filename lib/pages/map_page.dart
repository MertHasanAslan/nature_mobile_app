final coord = data['coordinates'];
LatLng? coordinates;
if (coord is GeoPoint) {
  coordinates = LatLng(coord.latitude, coord.longitude);
} else if (coord is Map && coord.containsKey('_latitude') && coord.containsKey('_longitude')) {
  coordinates = LatLng(coord['_latitude'], coord['_longitude']);
} else if (coord is List && coord.length == 2) {
  coordinates = LatLng(coord[0], coord[1]);
}
if (coordinates == null) continue; // Koordinat yoksa event'i atla 