import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'active_ride_provider.dart' show rideTripRepositoryProvider;
import 'matching_service_provider.dart' show matchingServiceProvider;

final rideRequestControllerProvider =
    AsyncNotifierProvider<RideRequestController, void>(
      RideRequestController.new,
    );

class RideRequestController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createRide({
    required String passengerId,
    required RideLocation pickup,
    required RideLocation dropoff,
    required double suggestedFare,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final ride = RideModel(
        id: '',
        passengerId: passengerId,
        driverId: null,
        pickup: pickup,
        dropoff: dropoff,
        status: RideStatus.requested,
        suggestedFare: suggestedFare,
        agreedFare: null,
        createdAt: Timestamp.now(),
      );

      final rideId = await ref.read(rideTripRepositoryProvider).createRide(ride);

      await ref
          .read(matchingServiceProvider.notifier)
          .startMatching(
            rideId: rideId,
            passengerId: passengerId,
            pickup: pickup,
            suggestedFare: suggestedFare,
          );
    });
  }

  Future<void> cancelRide(String rideId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(matchingServiceProvider.notifier).stopMatching();
      await ref.read(rideTripRepositoryProvider).cancelRide(rideId);
    });
  }
}
