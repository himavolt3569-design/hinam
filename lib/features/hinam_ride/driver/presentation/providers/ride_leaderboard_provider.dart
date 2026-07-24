import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_provider.dart';

final rideLeaderboardProvider = StreamProvider<List<RideDriverModel>>((ref) {
  return ref.watch(rideDriverRepositoryProvider).watchLeaderboard();
});
