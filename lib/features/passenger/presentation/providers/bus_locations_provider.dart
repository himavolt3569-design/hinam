import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/passenger/data/repositories/passenger_repository.dart';
import 'package:hinam/shared/models/bus_location_model.dart';

final busLocationsProvider = StreamProvider<List<BusLocationModel>>((ref) {
  return ref.watch(passengerRepositoryProvider).watchActiveBuses();
});

final publicBusesProvider = Provider<AsyncValue<List<BusLocationModel>>>((ref) {
  return ref
      .watch(busLocationsProvider)
      .whenData((buses) => buses.where((b) => b.busType == 'public').toList());
});

final singleBusProvider =
    StreamProvider.family<BusLocationModel?, String>((ref, driverId) {
  return ref.watch(passengerRepositoryProvider).watchSingleBus(driverId);
});
