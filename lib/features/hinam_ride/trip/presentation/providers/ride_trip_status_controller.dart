import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_ride_provider.dart' show rideTripRepositoryProvider;

final rideTripStatusControllerProvider =
    AsyncNotifierProvider<RideTripStatusController, void>(
      RideTripStatusController.new,
    );

class RideTripStatusController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markArrived(String rideId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(rideTripRepositoryProvider).markArrived(rideId),
    );
  }

  Future<void> startTrip(String rideId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(rideTripRepositoryProvider).startTrip(rideId),
    );
  }

  Future<void> completeTrip(String rideId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(rideTripRepositoryProvider).completeTrip(rideId),
    );
  }
}
