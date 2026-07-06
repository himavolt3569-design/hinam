import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_profile_provider.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_tracking_provider.dart';
import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart'
    show VerificationStatus;

final rideOnlineStatusProvider =
    AsyncNotifierProvider<RideOnlineStatusController, void>(
      RideOnlineStatusController.new,
    );

class RideOnlineStatusController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggle(String driverId) async {
    final driver = ref.read(rideDriverProfileProvider).asData?.value;
    if (driver == null || driver.verificationStatus != VerificationStatus.approved) {
      state = AsyncValue.error(
        StateError('Only approved drivers can go online.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final isTracking = ref.read(rideTrackingProvider).isTracking;
      final notifier = ref.read(rideTrackingProvider.notifier);

      if (isTracking) {
        await notifier.stopTracking(driverId);
      } else {
        await notifier.startTracking(driverId);
      }
    });
  }
}
