import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/shared/geo_utils.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';

const _baseFare = 50.0;
const _perKmRate = 25.0;

/// Pure suggested-fare calculation — no Firestore or network access.
/// Exposed as a provider only for consistency with how the rest of the app
/// reads values, not because it depends on any external state.
final suggestedFareProvider =
    Provider.family<double, ({RideLocation pickup, RideLocation dropoff})>((
      ref,
      locations,
    ) {
      final distanceKm = distanceInKm(
        fromLatitude: locations.pickup.latitude,
        fromLongitude: locations.pickup.longitude,
        toLatitude: locations.dropoff.latitude,
        toLongitude: locations.dropoff.longitude,
      );
      return _baseFare + (distanceKm * _perKmRate);
    });
