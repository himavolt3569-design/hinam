import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';
import 'ride_driver_provider.dart';

final rideDriverProfileProvider =
    AsyncNotifierProvider<RideDriverProfileNotifier, RideDriverModel?>(
      RideDriverProfileNotifier.new,
    );

class RideDriverProfileNotifier extends AsyncNotifier<RideDriverModel?> {
  @override
  Future<RideDriverModel?> build() async {
    return null;
  }

  Future<void> loadDriver(String uid) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return ref.read(rideDriverRepositoryProvider).getDriver(uid);
    });
  }
}
