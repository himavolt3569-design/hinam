import 'dart:math';

const earthRadiusKm = 6371.0;

/// Great-circle distance between two coordinates, in kilometers.
///
/// Lives here — not inside pricing/ or trip/ — because it has no meaning
/// specific to either submodule and is used by both (fare estimation and
/// nearest-driver matching). Takes raw coordinates rather than a domain
/// model so it stays independent of any one submodule's types.
double distanceInKm({
  required double fromLatitude,
  required double fromLongitude,
  required double toLatitude,
  required double toLongitude,
}) {
  final dLat = _degreesToRadians(toLatitude - fromLatitude);
  final dLng = _degreesToRadians(toLongitude - fromLongitude);

  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(fromLatitude)) *
          cos(_degreesToRadians(toLatitude)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

double _degreesToRadians(double degrees) => degrees * (pi / 180);
