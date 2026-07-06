import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/passenger/data/models/ride_passenger_model.dart';
import 'ride_passenger_provider.dart';

final ridePassengerProfileProvider =
    AsyncNotifierProvider<RidePassengerProfileNotifier, RidePassengerModel?>(
      RidePassengerProfileNotifier.new,
    );

class RidePassengerProfileNotifier
    extends AsyncNotifier<RidePassengerModel?> {
  @override
  Future<RidePassengerModel?> build() async {
    return null;
  }

  Future<void> loadPassenger(String uid) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return ref.read(ridePassengerRepositoryProvider).getPassenger(uid);
    });
  }
}
