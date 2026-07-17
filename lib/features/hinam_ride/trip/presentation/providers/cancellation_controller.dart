import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_ride_provider.dart' show rideTripRepositoryProvider;

final cancellationControllerProvider =
    AsyncNotifierProvider<CancellationController, void>(
      CancellationController.new,
    );

class CancellationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> cancel({
    required String rideId,
    required String cancelledBy,
    String? cancelReason,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(rideTripRepositoryProvider)
          .cancelRide(
            rideId,
            cancelledBy: cancelledBy,
            cancelReason: cancelReason,
          ),
    );
  }

  Future<void> markNoShow(String rideId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(rideTripRepositoryProvider).markNoShow(rideId),
    );
  }
}
