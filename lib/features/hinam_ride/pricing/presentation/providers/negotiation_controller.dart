import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/trip/presentation/providers/active_ride_provider.dart'
    show rideTripRepositoryProvider;

final negotiationControllerProvider =
    AsyncNotifierProvider<NegotiationController, void>(
      NegotiationController.new,
    );

class NegotiationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> acceptOffer({
    required String rideId,
    required String offerId,
    required String driverId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(rideTripRepositoryProvider)
          .acceptOffer(rideId: rideId, offerId: offerId, driverId: driverId);
    });
  }

  Future<void> declineOffer({
    required String rideId,
    required String offerId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(rideTripRepositoryProvider).declineOffer(rideId, offerId);
    });
  }

  Future<void> counterOffer({
    required String rideId,
    required String offerId,
    required double amount,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(rideTripRepositoryProvider)
          .counterOffer(rideId: rideId, offerId: offerId, amount: amount);
    });
  }
}
