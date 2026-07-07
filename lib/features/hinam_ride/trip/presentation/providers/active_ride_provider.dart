import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/trip/data/datasources/ride_trip_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_offer_model.dart';
import 'package:hinam/features/hinam_ride/trip/data/repositories/ride_trip_repository.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final rideTripDatasourceProvider = Provider<RideTripRemoteDatasource>(
  (ref) => RideTripRemoteDatasource(ref.read(firestoreProvider)),
);

final rideTripRepositoryProvider = Provider<RideTripRepository>(
  (ref) => RideTripRepository(ref.read(rideTripDatasourceProvider)),
);

final activeRideProvider = StreamProvider.family<RideModel?, String>((
  ref,
  passengerId,
) {
  return ref
      .watch(rideTripRepositoryProvider)
      .watchActiveRideForPassenger(passengerId);
});

final rideOffersProvider = StreamProvider.family<List<RideOfferModel>, String>(
  (ref, rideId) {
    return ref.watch(rideTripRepositoryProvider).watchOffersForRide(rideId);
  },
);
