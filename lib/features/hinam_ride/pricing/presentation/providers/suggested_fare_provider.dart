import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';

const _baseFare = 50.0;
const _perKmRate = 25.0;
const _earthRadiusKm = 6371.0;

/// Pure suggested-fare calculation — no Firestore or network access.
/// Exposed as a provider only for consistency with how the rest of the app
/// reads values, not because it depends on any external state.
final suggestedFareProvider =
    Provider.family<double, ({RideLocation pickup, RideLocation dropoff})>((
      ref,
      locations,
    ) {
      final distanceKm = _distanceInKm(locations.pickup, locations.dropoff);
      return _baseFare + (distanceKm * _perKmRate);
    });

double _distanceInKm(RideLocation from, RideLocation to) {
  final dLat = _degreesToRadians(to.latitude - from.latitude);
  final dLng = _degreesToRadians(to.longitude - from.longitude);

  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(from.latitude)) *
          cos(_degreesToRadians(to.latitude)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return _earthRadiusKm * c;
}

double _degreesToRadians(double degrees) => degrees * (pi / 180);
