import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/driver/data/models/driver_model.dart';
import 'driver_provider.dart';

final driverProfileProvider =
    AsyncNotifierProvider<DriverProfileNotifier, DriverModel?>(
      DriverProfileNotifier.new,
    );

class DriverProfileNotifier extends AsyncNotifier<DriverModel?> {
  @override
  Future<DriverModel?> build() async {
    return null;
  }

  Future<void> loadDriver(String uid) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return ref.read(driverRepositoryProvider).getDriver(uid);
    });
  }
}
